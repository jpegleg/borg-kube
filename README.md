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

#### Tips on stability

NeuVector does not work well in all cluster configurations, and it may crash, as of the time of this writing. 
Don't rely on it being up for critical operations, use it as an analysis and audit WUI.

Configuration and policy can be imported and exported on the settings page. Save the configuration when you get something useful, export it, so that when it inevitably crashes or you need to implement it in another cluster, the security can be treated as code. We don't want to have to have to have it "re-learn" all the policy after every crash, ideally :)

## Design choices

The Kubernetes API storage is sqlite based and encrypted at rest, although k3s stores the password on disk. 
It isn't perfect API storage encryption, but it better than default. This could be swapped out with HashiCorp Vault for secret storage driver etc. The k3s encrypted API storage does come with key rotation and can be automated.

This cluster is designed to utilize manifests and the k3s curl bash installer. Offline install can be done by loading the image tarballs with k3s ctr and using manifests locally. The NeuVector manifest is stored with it's license in `files/` with `local_neuvector_manifest_copy.yml` and `NEUVECTOR_LICENSE`. Neither of these files are normally required, but I wanted to include the NeuVector manifest being used locally for review purposes. See the executor `neu.sh` which uses k3s kubectl to create all of the RBAC, (PSP), and applies the NeuVector services via manifest.

The cluster starts out less secure in discovery mode, but can then be hardened via activity in the WUI, or via code of course.

The installation is done with some minimal ansible and shell. Feel free to change that, just keeping this one to the point.

Calico is configured to use wireguard and disable eBPF "dataplane" in Calico in this example.

```
---
apiVersion: projectcalico.org/v3
kind: FelixConfiguration
metadata:
  name: default
spec:
  bpfEnabled: false
  bpfDisableUnprivileged: true
  bpfKubeProxyIptablesCleanupEnabled: true
  wireguardEnabled: true
...
```


With this we ideally leave only some well protected area restricted for calicoctl and only calicoctl, via Kubernetes RBAC and network rules automation.



## Related documentation for NeuVector and Calico

- https://open-docs.neuvector.com/deploying/kubernetes
- https://projectcalico.docs.tigera.io/
