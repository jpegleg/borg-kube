# borg-kube 📦
Configure k3s with NeuVector and Calico. A Kubernetes build script that has automated security policy. 

Example building a cluster from hosts.ini with a single control plane of hosts category `borg1` and all other nodes as category `borg1` in the Ansible inventory.
```
[borg1]
192.168.1.144

[borg2]
192.168.1.131
192.168.1.130
192.168.1.132
```

Ensure ssh access for root is authorized, then apply the full formation playboook run:

```
anisble-playbook -u root -i hosts.ini cluster_formation.yml
anisble-playbook -u root -i hosts.ini cluster_net.yml
anisble-playbook -u root -i hosts.ini cluster_borg.yml
```

Then create your development projects and service deployments with a ServiceAccount via GitOps etc. After NeuVector has run in discover mode for a while with the deployments in use, switch items to Protect mode and adjust any autowritten rules. Then, we have NeuVector visibility, alerting, enforcement, and more.

NeuVector approach is less stable perhaps than a lighter resource solution like Tetragon combined with Wazuh.
However NeuVector does include many appealing features, such as CVE aggregation, and rule development automation,
as well as WAF, and active response automation. Wazuh and tetragon can accomplish most of these things, but the rule writing automation in NeuVector is superior at the time of this writing. See the tips section below when the WUI fails.

- current test targets 2022-08-16: Ubuntu 22
- next target: Leap 15

Make sure the nodes have ~1GB RAM available for NeuVector, in addition to the RAM needed for the workloads, as well as plenty of additional storage space.

Also see https://github.com/jpegleg/k3s-dragon-eggs for more k3s related ansible references and Calico concepts.

AppArmor on k3s has the potential to conflict with NeuVector, but I'm testing that area.
Not having AppArmor in Ubuntu can cause potential issues, so I'm testing that scenario out. 
It appears that so far most things are working, although I would not be surprised if some functionality is broken because of that, TBD.

#### I added a node to the cluster but it isn't showing up in NeuVector WUI - note

The replicas being 3 here is for when there were two servers and adding a third didn't show up.
After scaling the deployments up a notch, it started showing up. TBD on if this actually helped or was just timing.

```
kubectl scale --replicas=3 -n neuvector deployment/neuvector-scanner-pod
kubectl scale --replicas=3 -n neuvector deployment/neuvector-manager-pod
```
Another way to "clear" NeuVector during "unknown error" states, take it down and back up:

```
kubectl scale --replicas=0 -n neuvector deployment/neuvector-scanner-pod
kubectl scale --replicas=0 -n neuvector deployment/neuvector-manager-pod
kubectl scale --replicas=3 -n neuvector deployment/neuvector-scanner-pod
kubectl scale --replicas=3 -n neuvector deployment/neuvector-manager-pod
```

This may be a consequence of management via manifest...


## Design choices

This cluster is designed to utilize manifests and the k3s curl bash installer. Offline install can be done by loading the image tarballs with k3s ctr and using manifests locally.

The cluster starts out less secure in discovery mode, but can then be hardened via activity in the WUI.

The installation is done with some minimal ansible and shell. Feel free to change that, just keeping this one to the point.

Calico is configured to use wireguard and eBPF mode.

```
---
apiVersion: projectcalico.org/v3
kind: FelixConfiguration
metadata:
  name: default
spec:
  bpfEnabled: true
  bpfDisableUnprivileged: true
  bpfKubeProxyIptablesCleanupEnabled: true
  wireguardEnabled: true
  bpfExternalServiceMode: DSR
...
```


With this we ideally leave only some well protected area restricted for calicoctl and only calicoctl, via Kubernetes RBAC and network rules automation.



## Related documentation for NeuVector and Calico

- https://open-docs.neuvector.com/deploying/kubernetes
- https://projectcalico.docs.tigera.io/
