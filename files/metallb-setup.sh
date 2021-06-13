kubectl apply -f {{ metallb_setup.manifest_url }}/namespace.yaml
kubectl apply -f {{ metallb_setup.manifest_url }}/metallb.yaml 
