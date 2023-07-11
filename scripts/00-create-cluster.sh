#!/usr/bin/env bash

if [[ $(basename $(pwd)) == "scripts" ]]; then cd .. && echo "PWD=$(pwd)"; fi

# Reference: https://knative.dev/docs/install/quickstart-install/#run-the-knative-quickstart-plugin

if  command -v kn &> /dev/null
then
      echo "kn CLI is installed"
else
    echo "Installing kn CLI"
    brew install knative/client/kn
fi

brew install knative-sandbox/kn-plugins/quickstart

kind delete cluster --name pkg-demo
kn quickstart kind --name pkg-demo --install-serving
kapp deploy -a kapp-controller -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml -y
