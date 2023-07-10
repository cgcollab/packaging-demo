#!/usr/bin/env bash

if [[ $(basename $(pwd)) == "scripts" ]]; then cd .. && echo "PWD=$(pwd)"; fi
if [[ -z $MY_REG ]]; then echo "ERROR: Env is not set. Exiting script."; (return 0 2>/dev/null) && return || exit; fi

read -r -p "Skip prompts? [y/N] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]; then SKIP_PROMPTS_FLAG="--yes"; else SKIP_PROMPTS_FLAG=""; fi

#_ECHO_# What if the target location is air-gapped? imgpkg can help!
imgpkg copy -b $MY_REG/metapackage-repo:1.0.0 --to-repo $MY_REG-airgapped/metapackage-repo
imgpkg pull -b $MY_REG-airgapped/metapackage-repo:1.0.0 -o tmp/airgapped
tree -a tmp/airgapped
yq tmp/airgapped/.imgpkg/images.yml

# The original package repository contains all the images for all the packages in the repository.
# Let's build another package repository that only contains the necessary images
vendir sync --chdir repository $SKIP_PROMPTS_FLAG
kctrl package repo release --chdir repository/1.0.0-small --version 1.0.0-small $SKIP_PROMPTS_FLAG  #metapackage-repo.corp.com,taplab.azurecr.io/packaging-demo/metapackage-repo

#_ECHO_# What if the target location is air-gapped? imgpkg can help!
imgpkg copy -b $MY_REG/metapackage-repo:1.0.0-small --to-repo $MY_REG-edge/metapackage-repo
imgpkg pull -b $MY_REG-edge/metapackage-repo:1.0.0-small -o tmp/edge
tree -a tmp/edge
yq tmp/edge/.imgpkg/images.yml

kubectl cluster-info --context kind-pkg-demo-small
kubectl create ns metapackage-install
kctrl package repo add -r metapackage-repo --url $MY_REG-edge/metapackage-repo:1.0.0-small -n metapackage-install
#kctrl package repository list -A

kctrl package available list -A # shorthand: kctrl p a ls -A
kctrl package available get -p metapackage.corp.com -n metapackage-install
kctrl package available get -p metapackage.corp.com/1.0.0 --values-schema -n metapackage-install

#kubectl create ns hello-app
#kubectl create ns giant-app
kubectl create ns apps-small
kctrl package install -i my-metapackage -p metapackage.corp.com -v 1.0.0 -n metapackage-install --values-file values-small.yaml
