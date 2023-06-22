#!/usr/bin/env bash

kubectl create ns installs
kctrl package repo add -r app-repo --url gcr.io/fe-ciberkleid/app-repo:1.0.0 -n installs
kctrl package available list -A # shortthand: kctrl p a ls -A
kctrl package available get -p metapackage.corp.com -n installs
kctrl package available get -p metapackage.corp.com/1.0.0 --values-schema -n installs

kapp deploy -a rbac -f ns-rbac-default.yml --into-ns installs

kubectl create ns hello-app
kctrl package install -i my-app -p metapackage.corp.com -v 1.0.0 -n installs

# TROUBLESHOOTING
# In case of error, correct configuration errors and re-release corrected package, metapackage, and repo by re-running init commands with a "-y" flag
# Package installs will reconcile, but you can force an immediate reconciliation using the kick command for the repo and/or package install, as follows:
# kctrl p repo kick -r app-repo -n installs -y
# kctrl p i kick -i my-app -n installs -y

# To delete a package:
# kctrl p i delete -i my-app -n installs
# If deletion gets stuck, in separate terminal, run:
# kctrl p i delete -i redis -n installs --noop
# kctrl p i delete -i hello-app -n installs --noop