#_ECHO_OFF

# Pre-requisites: ./scripts/00-create-cluster.sh
# To run: ./scripts/demorunner.sh scripts/demo-consume-metapackage.sh

export MY_REG=taplab.azurecr.io/packaging-demo

kctrl package installed delete -i my-metapackage -n metapackage-install --yes
kctrl package repo delete -r metapackage-repo -n metapackage-install --yes

clear
#_ECHO_ON
kubectl create ns metapackage-install
kctrl package repo add -r metapackage-repo --url $MY_REG/metapackage-repo:1.0.0 -n metapackage-install
kctrl package available list -A # shorthand: kctrl p a ls -A
kctrl package available list -A --summary=false

kubectl create ns apps
yq values-full.yaml
kctrl package install -i my-metapackage -p metapackage.corp.com -v 1.0.0 -n metapackage-install --values-file values-full.yaml
kctrl package installed list -A
kubectl get kservice -A

yq values-medium.yaml
kctrl package install -i my-metapackage -p metapackage.corp.com -v 1.0.0 -n metapackage-install --values-file values-medium.yaml
kctrl package installed list -A
kubectl get kservice -n A
kubectl get all -n apps

## Test app
#echo "kubectl port-forward service/hello-app 8081:8080 -n apps"
#echo "http :8081"
##http :8081/random

#_ECHO_# What if the target location is air-gapped?
imgpkg copy -b $MY_REG/metapackage-repo:1.0.0 --to-repo $MY_REG-airgapped/metapackage-repo
#skopeo list-tags docker://$MY_REG-airgapped/metapackage-repo
imgpkg pull -b $MY_REG-airgapped/metapackage-repo:1.0.0 -o tmp/airgapped
tree -a tmp/airgapped
yq tmp/airgapped/.imgpkg/images.yml

#_ECHO_# What if the target location is tiny?
#_ECHO_# Release minimalist metapackage
yq repositories/vendir.yml
vendir sync --chdir repositories
tree -a repositories/1.0.0-small
# (Prompts: metapackage-repo.corp.com,taplab.azurecr.io/packaging-demo/metapackage-repo)
kctrl package repo release --chdir repositories/1.0.0-small --version 1.0.0-small
imgpkg copy -b $MY_REG/metapackage-repo:1.0.0-small --to-repo $MY_REG-edge/metapackage-repo
#skopeo list-tags docker://$MY_REG-edge/metapackage-repo
#imgpkg pull -b $MY_REG-edge/metapackage-repo:1.0.0-small -o tmp/edge
#tree -a tmp/edge
#yq tmp/edge/.imgpkg/images.yml

#_ECHO_# Clean cluster
kctrl package installed delete -i my-metapackage -n metapackage-install --yes
kctrl package repo delete -r metapackage-repo -n metapackage-install --yes 2>&1

kctrl package repo add -r metapackage-repo --url $MY_REG-edge/metapackage-repo:1.0.0-small -n metapackage-install
kctrl package available list -A

yq values-small.yaml
kubectl create ns apps-small
kctrl package install -i my-metapackage -p metapackage.corp.com -v 1.0.0 -n metapackage-install --values-file values-small.yaml
kctrl package installed list -A
