#!/usr/bin/env bash

if [[ $(basename $(pwd)) == "scripts" ]]; then cd .. && echo "PWD=$(pwd)"; fi
if [[ -z $MY_REG ]]; then echo "ERROR: Env is not set. Exiting script."; (return 0 2>/dev/null) && return || exit; fi
mkdir -p tmp/src/

read -r -p "Skip prompts? [y/N] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]; then SKIP_PROMPTS_FLAG="--yes"; else SKIP_PROMPTS_FLAG=""; fi

#----GIANT_APP
## giant-app - build app container
[[ -d tmp/src/giant-app ]] || git clone https://github.com/cgcollab/giant-app tmp/src/giant-app
myDest=$MY_REG/giant-app yq e -i 'select(.kind == "Config").destinations[0].newImage = env(myDest)' tmp/src/giant-app/kbld.yml
#yq eval -i 'select(.kind == "Config").destinations[0].tags += ["3.5.1"] | select(.kind == "Config").destinations[0].tags = (select(.kind == "Config").destinations[0].tags | unique)' tmp/src/giant-app/kbld.yml
pushd tmp/src/giant-app && kbld -f kbld.yml -f manifest.lock --lock-output manifest.lock && popd
# giant-app - init & release package
myDest=$MY_REG/giant-app:3.5.1 yq e -i 'select(.kind == "Deployment").spec.template.spec.containers[0].image = env(myDest)' packages/giant-app/config/config.yml
kctrl package init --chdir packages/giant-app $SKIP_PROMPTS_FLAG # Prompts: giant-app.corp.com,1,config
kctrl package release --chdir packages/giant-app --version 3.5.1 --repo-output ../../repository/1.0.0 $SKIP_PROMPTS_FLAG # Prompts: <YOUR REG + "/giant-app">

##----HELLO_APP
## hello-app - build app container
[[ -d tmp/src/hello-app ]] || git clone https://github.com/cgcollab/hello-app tmp/src/hello-app
myDest=$MY_REG/hello-app yq e -i 'select(.kind == "Config").destinations[0].newImage = env(myDest)' tmp/src/hello-app/kbld.yml
#yq eval -i 'select(.kind == "Config").destinations[0].tags += ["1.2.3"] | select(.kind == "Config").destinations[0].tags = (select(.kind == "Config").destinations[0].tags | unique)' tmp/src/hello-app/kbld.yml
pushd tmp/src/hello-app && kbld -f kbld.yml -f manifest.lock --lock-output manifest.lock && popd
# hello-app - init & release package
myDest=$MY_REG/hello-app:1.2.3 yq e -i 'select(.kind == "Deployment").spec.template.spec.containers[0].image = env(myDest)' packages/hello-app/config/config.yml
kctrl package init --chdir packages/hello-app $SKIP_PROMPTS_FLAG  # Prompts: hello-app.corp.com,1,config
kctrl package release --chdir packages/hello-app --version 1.2.3 --repo-output ../../repository/1.0.0 $SKIP_PROMPTS_FLAG # Prompts: <YOUR REG + "/hello-app">

#----REDIS
# redis - init & release package
kctrl package init --chdir packages/hello-redis $SKIP_PROMPTS_FLAG # Prompts: hello-redis.corp.com,4,https://github.com/cgcollab/redis,origin/main,redis-*
# manually add overlays directory to be included in package and imgpkg (CRD ref: https://carvel.dev/kapp-controller/docs/v0.46.0/packaging/#package-build)
yq eval -i '.spec.template.spec.app.spec.template[0].ytt.paths += ["overlays"] | .spec.template.spec.app.spec.template[0].ytt.paths = (.spec.template.spec.app.spec.template[0].ytt.paths | unique)' packages/hello-redis/package-build.yml
yq eval -i '.spec.template.spec.export[0].includePaths += ["overlays"] | .spec.template.spec.export[0].includePaths = (.spec.template.spec.export[0].includePaths | unique)' packages/hello-redis/package-build.yml
# Run init again after yq changes, ANSWER 1 IN THE FINAL PROMPT TO AUTOMATICALLY UPDATE package-resources.yml based on changes made to package-build.yml
kctrl package init --chdir packages/hello-redis $SKIP_PROMPTS_FLAG # Prompts: hello-redis.corp.com,4,https://github.com/cgcollab/redis,origin/main,redis-*,1
kctrl package release --chdir packages/hello-redis --version 2.1.0 --repo-output ../../repository/1.0.0 $SKIP_PROMPTS_FLAG # Prompts: <YOUR REG + "/hello-redis">

#----METAPACKAGE
# metapackage (append metapackage version to repo-output path) - init & release package
kctrl package init --chdir packages/metapackage $SKIP_PROMPTS_FLAG # Prompts: metapackage.corp.com,1,config
kctrl package release --chdir packages/metapackage --version 1.0.0 --repo-output ../../repository/1.0.0 $SKIP_PROMPTS_FLAG # Prompts: <YOUR REG + "/metapackage">


#----RELEASE the REPO
# Release repository (use same version that was used for the metapackage)
kctrl package repository release --chdir repository/1.0.0 --version 1.0.0 $SKIP_PROMPTS_FLAG # Prompts: metapackage-repo.corp.com,<YOUR REG + "/metapackage-repo">


#----REUSE a subset of PKGS in another REPO
#$MY_REG/metapackage-repo:1.0.0

skopeo list-tags docker://taplab.azurecr.io/packaging-demo/giant-app
skopeo list-tags docker://taplab.azurecr.io/packaging-demo/hello-app
skopeo list-tags docker://taplab.azurecr.io/packaging-demo/hello-redis
skopeo list-tags docker://taplab.azurecr.io/packaging-demo/metapackage
skopeo list-tags docker://taplab.azurecr.io/packaging-demo/metapackage-repo
