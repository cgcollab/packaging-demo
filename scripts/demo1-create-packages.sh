#_ECHO_OFF

# Pre-requisites:
#   1. Set the url of your registry for example: export MY_REG=taplab.azurecr.io/packaging-demo
#       export MY_REG=taplab.azurecr.io/packaging-demo
#   2. Log in to your registry using `docker login`
#   3. Create a local branch and a clean directories
#     Run: ./scripts/00-start-state.sh
#   4. Build the test applications to be packaged
#     Run: ./scripts/00-build-apps.sh

# To execute the demo:
#  (Optional) Set the delay to simulate live typing (0 is no delay, 15 is the default delay)
#  export DEMO_DELAY=0
#  ./scripts/demorunner.sh scripts/demo1-create-packages.sh

myDest=$MY_REG/giant-app:3.5.1 yq e -i 'select(.template.spec.containers[0].name == "giant-app").template.spec.containers[0].image = env(myDest)' packages/giant-app/config/config.yaml
myDest=$MY_REG/hello-app:1.2.3 yq e -i 'select(.template.spec.containers[0].name == "hello-app").template.spec.containers[0].image = env(myDest)' packages/hello-app/config/config.yaml

clear
#_ECHO_ON

#----GIANT-APP
tree packages/giant-app
#_ECHO_# Init giant-app pkg. Prompts: giant-app.corp.com,1,config
kctrl package init --chdir packages/giant-app
tree packages/giant-app
yq packages/giant-app/package-build.yml
yq packages/giant-app/package-resources.yml

tree repositories/1.0.0/packages/giant-app.corp.com
#_ECHO_# Release giant-app pkg. Prompts: taplab.azurecr.io/packaging-demo/giant-app
kctrl package release --chdir packages/giant-app --version 3.5.1 --repo-output ../../repositories/1.0.0
tree repositories/1.0.0/packages/giant-app.corp.com
yq repositories/1.0.0/packages/giant-app.corp.com/3.5.1.yml
#_ECHO_# Compare with package-resources.yml before release
diff -y packages/giant-app/package-resources.yml repositories/1.0.0/packages/giant-app.corp.com/3.5.1.yml

clear
#----HELLO-APP
#_ECHO_# Init hello-app pkg. Prompts: hello-app.corp.com,1,config
kctrl package init --chdir packages/hello-app
#_ECHO_# Release hello-app pkg. Prompts: taplab.azurecr.io/packaging-demo/hello-app
kctrl package release --chdir packages/hello-app --version 1.2.3 --repo-output ../../repositories/1.0.0

clear
#----REDIS
tree packages/hello-redis
#_ECHO_# Init hello-redis pkg. Prompts: hello-redis.corp.com,4,https://github.com/cgcollab/redis,origin/main,redis-*
kctrl package init --chdir packages/hello-redis
tree packages/hello-redis
#_ECHO_OFF
# Draining some vendir extra output
yq packages/hello-redis/vendir.yml >/dev/null 2>/dev/null
#_ECHO_ON
yq packages/hello-redis/vendir.yml
# manually add overlays directory to be included in package and imgpkg (CRD ref: https://carvel.dev/kapp-controller/docs/v0.46.0/packaging/#package-build)
#_ECHO_OFF
yq eval -i '.spec.template.spec.app.spec.template[0].ytt.paths += ["overlays"] | .spec.template.spec.app.spec.template[0].ytt.paths = (.spec.template.spec.app.spec.template[0].ytt.paths | unique)' packages/hello-redis/package-build.yml
yq eval -i '.spec.template.spec.export[0].includePaths += ["overlays"] | .spec.template.spec.export[0].includePaths = (.spec.template.spec.export[0].includePaths | unique)' packages/hello-redis/package-build.yml
# Run init again after yq changes, ANSWER 1 IN THE FINAL PROMPT TO AUTOMATICALLY UPDATE package-resources.yml based on changes made to package-build.yml
#_ECHO_# Re-initialize hello-redis pkg to add local overlay config. Prompts: all same, last one: 1
kctrl package init --chdir packages/hello-redis --yes
#_ECHO_ON
#_ECHO_# Release hello-redis. Prompts: taplab.azurecr.io/packaging-demo/hello-redis
kctrl package release --chdir packages/hello-redis --version 2.1.0 --repo-output ../../repositories/1.0.0

clear
#----METAPACKAGE
# metapackage (append metapackage version to repo-output path) - init & release package
tree packages/metapackage
yq packages/metapackage/config/pkgi/hello-redis.yaml
tree repositories/1.0.0/
#_ECHO_# Init metapackage pkg. Prompts: metapackage.corp.com,1,config
kctrl package init --chdir packages/metapackage
#_ECHO_# Release metapackage pkg. Prompts: taplab.azurecr.io/packaging-demo/metapackage
kctrl package release --chdir packages/metapackage --version 1.0.0 --repo-output ../../repositories/1.0.0
tree repositories/1.0.0/

clear
#----RELEASE the REPO
# Release repository (use same version that was used for the metapackage)
#_ECHO_# Release repository. Prompts: metapackage-repo.corp.com,taplab.azurecr.io/packaging-demo/metapackage-repo
kctrl package repository release --chdir repositories/1.0.0 --version 1.0.0

skopeo list-tags docker://$MY_REG/giant-app
skopeo list-tags docker://$MY_REG/hello-app
skopeo list-tags docker://$MY_REG/hello-redis
skopeo list-tags docker://$MY_REG/metapackage
skopeo list-tags docker://$MY_REG/metapackage-repo
