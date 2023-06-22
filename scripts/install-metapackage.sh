#!/usr/bin/env bash

# kind create cluster
# kapp deploy -a kapp-controller -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml -y

kubectl create ns carvel-repos
kctrl package repo add -r metapackage-repo --url gcr.io/fe-ciberkleid/metapackage-repo:1.0.0 -n carvel-repos
kctrl package repository list -A

kctrl package available list -A # shorthand: kctrl p a ls -A
kctrl package available get -p metapackage.corp.com -n carvel-repos
kctrl package available get -p metapackage.corp.com/1.0.0 --values-schema -n carvel-repos

kubectl create ns hello-app
kubectl create ns metapackage-app
kctrl package install -i my-metapackage -p metapackage.corp.com -v 1.0.0 -n metapackage-install

# TROUBLESHOOTING
# In case of error, correct configuration errors and re-release corrected package, metapackage, and repo by re-running init commands with a "-y" flag
# See scripts/update-packages.sh

# To delete a package:
# kctrl p i delete -i my-app -n installs
# If deletion gets stuck, in separate terminal, run:
# kctrl p i delete -i redis -n installs --noop
# kctrl p i delete -i hello-app -n installs --noop