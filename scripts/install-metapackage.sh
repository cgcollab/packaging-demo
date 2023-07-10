#!/usr/bin/env bash

if [[ $(basename $(pwd)) == "scripts" ]]; then cd .. && echo "PWD=$(pwd)"; fi
if [[ -z $MY_REG ]]; then echo "ERROR: Env is not set. Exiting script."; (return 0 2>/dev/null) && return || exit; fi

# Reference: https://knative.dev/docs/install/quickstart-install/#run-the-knative-quickstart-plugin
# One time:
### brew install knative/client/kn
### brew install knative-sandbox/kn-plugins/quickstart
kind delete cluster --name pkg-demo
kn quickstart kind --name pkg-demo --install-serving
### kind delete cluster
### kind create cluster
kapp deploy -a kapp-controller -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml -y

kubectl create ns metapackage-install
kctrl package repo add -r metapackage-repo --url $MY_REG/metapackage-repo:1.0.0 -n metapackage-install
#kctrl package repository list -A

kctrl package available list -A # shorthand: kctrl p a ls -A
kctrl package available get -p metapackage.corp.com -n metapackage-install
kctrl package available get -p metapackage.corp.com/1.0.0 --values-schema -n metapackage-install

#kubectl create ns hello-app
#kubectl create ns giant-app
kubectl create ns apps
kctrl package install -i my-metapackage -p metapackage.corp.com -v 1.0.0 -n metapackage-install --values-file values.yaml

# Test app
kubectl port-forward service/hello-app 8081:8080 -n apps
http :8081
#http :8081/random

# TROUBLESHOOTING
# In case of error, correct configuration errors and re-release corrected package, metapackage, and repo by re-running init commands with a "-y" flag
# See scripts/update-packages.sh

# To delete a package:
# kctrl p i delete -i my-metapackage -n metapackage-install
# If deletion gets stuck, in separate terminal, run:
# kctrl p i delete -i hello-redis -n metapackage-install --noop
# kctrl p i delete -i hello-app -n metapackage-install --noop