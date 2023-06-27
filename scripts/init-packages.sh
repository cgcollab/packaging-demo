export MY_REG=taplab.azurecr.io/packaging-demo

# hello-app - build app container
mkdir -p tmp/src/hello-app && rm -rf tmp/src/hello-app && git clone https://github.com/cgcollab/hello-app tmp/src/hello-app
myDest=$MY_REG/hello-app yq e -i 'select(.kind == "Config").destinations[0].newImage = env(myDest)' tmp/src/hello-app/kbld.yml
kbld -f tmp/src/hello-app/kbld.yml

# hello-app - init & release package
myDest=$MY_REG/hello-app yq e -i 'select(.kind == "Deployment").spec.template.spec.containers[0].image = env(myDest)' packages/hello-app/config/config.yml

kctrl package init --chdir packages/hello-app # Prompts: hello-app.corp.com,1,config
kctrl package release --chdir packages/hello-app --version 1.2.3 --repo-output ../../repository/1.0.0 # Prompts: <YOUR REG + "/hello-app">

# redis - init & release package
kctrl package init --chdir packages/redis  # Prompts: redis.corp.com,4,https://github.com/cgcollab/redis,origin/main,redis-*
# manually add overlays directory to be included in package and imgpkg (CRD ref: https://carvel.dev/kapp-controller/docs/v0.46.0/packaging/#package-build)
yq eval -i '.spec.template.spec.app.spec.template[0].ytt.paths += ["overlays"] | .spec.template.spec.app.spec.template[0].ytt.paths = (.spec.template.spec.app.spec.template[0].ytt.paths | unique)' packages/redis/package-build.yml
yq eval -i '.spec.template.spec.export[0].includePaths += ["overlays"] | .spec.template.spec.export[0].includePaths = (.spec.template.spec.export[0].includePaths | unique)' packages/redis/package-build.yml
# Run init again after yq changes, ANSWER 1 IN THE FINAL PROMPT TO AUTOMATICALLY UPDATE package-resources.yml based on changes made to package-build.yml
kctrl package init --chdir packages/redis # Prompts: redis.corp.com,4,https://github.com/cgcollab/redis,origin/main,redis-*,1
kctrl package release --chdir packages/redis --version 2.1.0 --repo-output ../../repository/1.0.0 # Prompts: <YOUR REG + "/redis">

# metapackage (append metapackage version to repo-output path) - init & release package
kctrl package init --chdir packages/metapackage # Prompts: metapackage.corp.com,1,config
kctrl package release --chdir packages/metapackage --version 1.0.0 --repo-output ../../repository/1.0.0 # Prompts: <YOUR REG + "/metapackage">

# Release repository (use same version that was used for the metapackage)
kctrl package repository release --chdir repository/1.0.0 --version 1.0.0  # Prompts: metapackage-repo.corp.com,<YOUR REG + "/metapackage-repo">
