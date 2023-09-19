#_ECHO_OFF

# Pre-requisites:
#   1. Set the url of your registry for example: export MY_REG=taplab.azurecr.io/packaging-demo
#       export MY_REG=taplab.azurecr.io/packaging-demo
#   2. Log in to your registry using `docker login`
#   3. Set up a local cluster
#      Run: ./scripts/00-create-cluster.sh
#      Note: After the demo, you can delete the cluster using `kind delete cluster --name knative`

# To execute the demo:
#  (Optional) Set the delay to simulate live typing (0 is no delay, 15 is the default delay)
#  export DEMO_DELAY=0
#  ./scripts/demorunner.sh scripts/demo2-consume-packages.sh

# Cleanup from a previous run
kctrl package installed delete -i my-metapackage -n metapackage-install --yes
kubectl delete ns apps
kubectl delete ns apps-small
kctrl package repo delete -r metapackage-repo -n metapackage-install --yes
kubectl delete ns metapackage-install

clear
#_ECHO_ON
kubectl get ns

kubectl create ns metapackage-install
kctrl package repo add -r metapackage-repo --url $MY_REG/metapackage-repo:1.0.0 -n metapackage-install

clear
#kctrl package available list -A # shorthand: kctrl p a ls -A
kctrl package available list -A --summary=false

kubectl create ns apps
yq values-full.yaml
kctrl package install -i my-metapackage -p metapackage.corp.com -v 1.0.0 -n metapackage-install --values-file values-full.yaml
kctrl package installed list -A
kubectl get kservice -A

yq values-medium.yaml
kctrl package install -i my-metapackage -p metapackage.corp.com -v 1.0.0 -n metapackage-install --values-file values-medium.yaml
kctrl package installed list -A
kubectl get kservice -A
kubectl get all -n apps
#echo "kubectl port-forward service/hello-app 8081:8080 -n apps"
#echo "http :8081"

#_ECHO_# What if the target location is air-gapped?
imgpkg copy -b $MY_REG/metapackage-repo:1.0.0 --to-repo $MY_REG-airgapped/metapackage-repo
#skopeo list-tags docker://$MY_REG-airgapped/metapackage-repo
imgpkg pull -b $MY_REG-airgapped/metapackage-repo:1.0.0 -o tmp/airgapped
tree -a tmp/airgapped
yq tmp/airgapped/.imgpkg/images.yml

# Can also use kind's local registry:
#imgpkg copy -b $MY_REG/metapackage-repo:1.0.0 --to-repo localhost:5001/metapackage-repo
#imgpkg pull -b localhost:5001/metapackage-repo:1.0.0 -o tmp/airgapped-local
#tree -a tmp/airgapped-local
#yq tmp/airgapped-local/.imgpkg/images.yml

#_ECHO_# What if the target location is tiny?
#_ECHO_# Release minimalist metapackage
yq repositories/vendir.yml
vendir sync --chdir repositories
tree -a repositories/1.0.0-small
#_ECHO_# Release repo. Prompts: metapackage-repo.corp.com,taplab.azurecr.io/packaging-demo/metapackage-repo
kctrl package repo release --chdir repositories/1.0.0-small --version 1.0.0-small

imgpkg copy -b $MY_REG/metapackage-repo:1.0.0-small --to-repo $MY_REG-edge/metapackage-repo
#skopeo list-tags docker://$MY_REG-edge/metapackage-repo

#_ECHO_# Clean cluster
kctrl package installed delete -i my-metapackage -n metapackage-install --yes
kctrl package repo delete -r metapackage-repo -n metapackage-install --yes 2>&1

kctrl package repo add -r metapackage-repo --url $MY_REG-edge/metapackage-repo:1.0.0-small -n metapackage-install
kctrl package available list -A

yq values-small.yaml
kubectl create ns apps-small
kctrl package install -i my-metapackage -p metapackage.corp.com -v 1.0.0 -n metapackage-install --values-file values-small.yaml
kctrl package installed list -A
kubectl get pods -n apps-small
