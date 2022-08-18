#!/usr/bin/env bash
# k3s applying free NeuVector manifests
k3s kubectl create namespace neuvector
# note: psp is deprecated now, this will eventually change
k3s kubectl create -f nv_psp.yml 
# the CRDs
k3s kubectl apply -f https://raw.githubusercontent.com/neuvector/manifests/main/kubernetes/5.0.0/crd-k8s-1.19.yaml
k3s kubectl apply -f https://raw.githubusercontent.com/neuvector/manifests/main/kubernetes/5.0.0/waf-crd-k8s-1.19.yaml
k3s kubectl apply -f https://raw.githubusercontent.com/neuvector/manifests/main/kubernetes/5.0.0/dlp-crd-k8s-1.19.yaml
k3s kubectl apply -f https://raw.githubusercontent.com/neuvector/manifests/main/kubernetes/5.0.0/admission-crd-k8s-1.19.yaml
# the RBAC
k3s kubectl create clusterrole neuvector-binding-app --verb=get,list,watch,update --resource=nodes,pods,services,namespaces
k3s kubectl create clusterrole neuvector-binding-rbac --verb=get,list,watch --resource=rolebindings.rbac.authorization.k8s.io,roles.rbac.authorization.k8s.io,clusterrolebindings.rbac.authorization.k8s.io,clusterroles.rbac.authorization.k8s.io
k3s kubectl create clusterrolebinding neuvector-binding-app --clusterrole=neuvector-binding-app --serviceaccount=neuvector:default
k3s kubectl create clusterrolebinding neuvector-binding-rbac --clusterrole=neuvector-binding-rbac --serviceaccount=neuvector:default
k3s kubectl create clusterrole neuvector-binding-admission --verb=get,list,watch,create,update,delete --resource=validatingwebhookconfigurations,mutatingwebhookconfigurations
k3s kubectl create clusterrolebinding neuvector-binding-admission --clusterrole=neuvector-binding-admission --serviceaccount=neuvector:default
k3s kubectl create clusterrole neuvector-binding-customresourcedefinition --verb=watch,create,get,update --resource=customresourcedefinitions
k3s kubectl create clusterrolebinding  neuvector-binding-customresourcedefinition --clusterrole=neuvector-binding-customresourcedefinition --serviceaccount=neuvector:default
k3s kubectl create clusterrole neuvector-binding-nvsecurityrules --verb=list,delete --resource=nvsecurityrules,nvclustersecurityrules
k3s kubectl create clusterrolebinding neuvector-binding-nvsecurityrules --clusterrole=neuvector-binding-nvsecurityrules --serviceaccount=neuvector:default
k3s kubectl create clusterrolebinding neuvector-binding-view --clusterrole=view --serviceaccount=neuvector:default
k3s kubectl create rolebinding neuvector-admin --clusterrole=admin --serviceaccount=neuvector:default -n neuvector
k3s kubectl create clusterrole neuvector-binding-nvwafsecurityrules --verb=list,delete --resource=nvwafsecurityrules
k3s kubectl create clusterrolebinding neuvector-binding-nvwafsecurityrules --clusterrole=neuvector-binding-nvwafsecurityrules --serviceaccount=neuvector:default
k3s kubectl create clusterrole neuvector-binding-nvadmissioncontrolsecurityrules --verb=list,delete --resource=nvadmissioncontrolsecurityrules
k3s kubectl create clusterrolebinding neuvector-binding-nvadmissioncontrolsecurityrules --clusterrole=neuvector-binding-nvadmissioncontrolsecurityrules --serviceaccount=neuvector:default
k3s kubectl create clusterrole neuvector-binding-nvdlpsecurityrules --verb=list,delete --resource=nvdlpsecurityrules
k3s kubectl create clusterrolebinding neuvector-binding-nvdlpsecurityrules --clusterrole=neuvector-binding-nvdlpsecurityrules --serviceaccount=neuvector:default
# the manifest
k3s kubectl apply -f https://raw.githubusercontent.com/neuvector/manifests/main/kubernetes/5.0.0/neuvector-rancher-containerd-k3s.yaml
