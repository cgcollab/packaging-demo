#!/usr/bin/env bash

if [[ $(basename $(pwd)) == "scripts" ]]; then cd .. && echo "PWD=$(pwd)"; fi
if [[ -z $MY_REG ]]; then echo "ERROR: Env is not set. Exiting script."; (return 0 2>/dev/null) && return || exit; fi

kubectl create ns metapackage-install
kctrl package repo add -r metapackage-repo --url $MY_REG/metapackage-repo:1.0.0 -n metapackage-install
#kctrl package repository list -A

kctrl package available list -A # shorthand: kctrl p a ls -A
#kctrl package available get -p metapackage.corp.com -n metapackage-install
#kctrl package available get -p metapackage.corp.com/1.0.0 --values-schema -n metapackage-install

#kubectl create ns hello-app
#kubectl create ns giant-app
kubectl create ns apps
yq values-full.yaml
kctrl package install -i my-metapackage -p metapackage.corp.com -v 1.0.0 -n metapackage-install --values-file values-full.yaml
kctrl package installed list -A
kubectl get kservice -A

yq values-medium.yaml
kctrl package install -i my-metapackage -p metapackage.corp.com -v 1.0.0 -n metapackage-install --values-file values-medium.yaml
kctrl package installed list -A
kubectl get kservice -n A
kubectl get service -n apps

# Test app
kubectl port-forward service/hello-app 8081:8080 -n apps
http :8081
#http :8081/random
