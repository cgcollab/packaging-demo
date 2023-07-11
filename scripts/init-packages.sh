#!/usr/bin/env bash

if [[ $(basename $(pwd)) == "scripts" ]]; then cd .. && echo "PWD=$(pwd)"; fi
if [[ -z $MY_REG ]]; then echo "ERROR: Env is not set. Exiting script."; (return 0 2>/dev/null) && return || exit; fi

read -r -p "Skip prompts? [y/N] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]; then SKIP_PROMPTS_FLAG="--yes"; else SKIP_PROMPTS_FLAG=""; fi

#----GIANT_APP
# giant-app - init & release package
myDest=$MY_REG/giant-app:3.5.1 yq e -i 'select(.template.spec.containers[0].name == "giant-app").template.spec.containers[0].image = env(myDest)' packages/giant-app/config/config.yaml
kctrl package init --chdir packages/giant-app $SKIP_PROMPTS_FLAG # Prompts: giant-app.corp.com,1,config
kctrl package release --chdir packages/giant-app --version 3.5.1 --repo-output ../../repositories/1.0.0 $SKIP_PROMPTS_FLAG # Prompts: taplab.azurecr.io/packaging-demo/giant-app

##----HELLO_APP
# hello-app - init & release package
myDest=$MY_REG/hello-app:1.2.3 yq e -i 'select(.template.spec.containers[0].name == "hello-app").template.spec.containers[0].image = env(myDest)' packages/hello-app/config/config.yaml
kctrl package init --chdir packages/hello-app $SKIP_PROMPTS_FLAG  # Prompts: hello-app.corp.com,1,config
kctrl package release --chdir packages/hello-app --version 1.2.3 --repo-output ../../repositories/1.0.0 $SKIP_PROMPTS_FLAG # Prompts: taplab.azurecr.io/packaging-demo/hello-app

#----REDIS
# redis - init & release package
kctrl package init --chdir packages/hello-redis $SKIP_PROMPTS_FLAG # Prompts: hello-redis.corp.com,4,https://github.com/cgcollab/redis,origin/main,redis-*
# manually add overlays directory to be included in package and imgpkg (CRD ref: https://carvel.dev/kapp-controller/docs/v0.46.0/packaging/#package-build)
yq eval -i '.spec.template.spec.app.spec.template[0].ytt.paths += ["overlays"] | .spec.template.spec.app.spec.template[0].ytt.paths = (.spec.template.spec.app.spec.template[0].ytt.paths | unique)' packages/hello-redis/package-build.yml
yq eval -i '.spec.template.spec.export[0].includePaths += ["overlays"] | .spec.template.spec.export[0].includePaths = (.spec.template.spec.export[0].includePaths | unique)' packages/hello-redis/package-build.yml
# Run init again after yq changes, ANSWER 1 IN THE FINAL PROMPT TO AUTOMATICALLY UPDATE package-resources.yml based on changes made to package-build.yml
kctrl package init --chdir packages/hello-redis $SKIP_PROMPTS_FLAG # Prompts: hello-redis.corp.com,4,https://github.com/cgcollab/redis,origin/main,redis-*,1
kctrl package release --chdir packages/hello-redis --version 2.1.0 --repo-output ../../repositories/1.0.0 $SKIP_PROMPTS_FLAG # Prompts: taplab.azurecr.io/packaging-demo/hello-redis

#----METAPACKAGE
# metapackage (append metapackage version to repo-output path) - init & release package
kctrl package init --chdir packages/metapackage $SKIP_PROMPTS_FLAG # Prompts: metapackage.corp.com,1,config
kctrl package release --chdir packages/metapackage --version 1.0.0 --repo-output ../../repositories/1.0.0 $SKIP_PROMPTS_FLAG # Prompts: taplab.azurecr.io/packaging-demo/metapackage


#----RELEASE the REPO
# Release repository (use same version that was used for the metapackage)
kctrl package repository release --chdir repositories/1.0.0 --version 1.0.0 $SKIP_PROMPTS_FLAG # Prompts: metapackage-repo.corp.com,taplab.azurecr.io/packaging-demo/metapackage-repo

skopeo list-tags docker://$MY_REG/giant-app
skopeo list-tags docker://$MY_REG/hello-app
skopeo list-tags docker://$MY_REG/hello-redis
skopeo list-tags docker://$MY_REG/metapackage
skopeo list-tags docker://$MY_REG/metapackage-repo
