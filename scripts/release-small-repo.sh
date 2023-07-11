#!/usr/bin/env bash

if [[ $(basename $(pwd)) == "scripts" ]]; then cd .. && echo "PWD=$(pwd)"; fi
if [[ -z $MY_REG ]]; then echo "ERROR: Env is not set. Exiting script."; (return 0 2>/dev/null) && return || exit; fi

read -r -p "Skip prompts? [y/N] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]; then SKIP_PROMPTS_FLAG="--yes"; else SKIP_PROMPTS_FLAG=""; fi

#_ECHO_# What if the target location is air-gapped?
imgpkg copy -b $MY_REG/metapackage-repo:1.0.0 --to-repo $MY_REG-airgapped/metapackage-repo
#skopeo list-tags docker://$MY_REG-airgapped/metapackage-repo
imgpkg pull -b $MY_REG-airgapped/metapackage-repo:1.0.0 -o tmp/airgapped
tree -a tmp/airgapped
yq tmp/airgapped/.imgpkg/images.yml

#_ECHO_# What if the target location is tiny?
# The original package repository contains all the images for all the packages in the repository.
# Let's build another package repository that only contains the necessary images
vendir sync --chdir repositories $SKIP_PROMPTS_FLAG
echo "Release minimalist metapackage. Prompts: metapackage-repo.corp.com,taplab.azurecr.io/packaging-demo/metapackage-repo"
kctrl package repo release --chdir repositories/1.0.0-small --version 1.0.0-small # ASK SOUMIK!!!! $SKIP_PROMPTS_FLAG
imgpkg copy -b $MY_REG/metapackage-repo:1.0.0-small --to-repo $MY_REG-edge/metapackage-repo
#skopeo list-tags docker://$MY_REG-edge/metapackage-repo
imgpkg pull -b $MY_REG-edge/metapackage-repo:1.0.0-small -o tmp/edge
tree -a tmp/edge
yq tmp/edge/.imgpkg/images.yml

# Clean cluster (kn quickstart cannot start 2 concurrent clusters because use of port 80 is not configurable)
kctrl package installed delete -i my-metapackage -n metapackage-install --yes
kctrl package repo delete -r metapackage-repo -n metapackage-install --yes

kctrl package repo add -r metapackage-repo --url $MY_REG-edge/metapackage-repo:1.0.0-small -n metapackage-install
kctrl package available list -A

#kubectl create ns hello-app
#kubectl create ns giant-app
yq values-small.yaml
kubectl create ns apps-small
kctrl package install -i my-metapackage -p metapackage.corp.com -v 1.0.0 -n metapackage-install --values-file values-small.yaml
