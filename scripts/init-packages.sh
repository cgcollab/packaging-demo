export MY_REG=gcr.io/fe-ciberkleid/packaging-demo

# hello-app - init & release package
myDest=$MY_REG/hello-app yq e -i '.destinations[0].newImage = env(myDest)' packages/hello-app/config/kbld.yml
mkdir -p tmp/src/hello-app && rm -rf tmp/src/hello-app && git clone https://github.com/cgcollab/hello-app tmp/src/hello-app
kctrl package init --chdir packages/hello-app # Prompts: hello-app.corp.com,1,config
kctrl package release --chdir packages/hello-app --version 1.2.3 --repo-output ../../repository/1.0.0 # Prompts: <YOUR REG + "/hello-app">

# redis - init & release package
kctrl package init --chdir packages/redis # Prompts: redis.corp.com,4,https://github.com/cgcollab/redis,origin/main,redis-*
# manuallly add overlays directory to be included in package and imgpkg (CRD ref: https://carvel.dev/kapp-controller/docs/v0.46.0/packaging/#package-build)
yq eval -i '.spec.template.spec.app.spec.template[0].ytt.paths += ["overlays"]' packages/redis/package-build.yml
yq eval -i '.spec.template.spec.export[0].includePaths += ["overlays"]' packages/redis/package-build.yml
kctrl package release --chdir packages/redis --version 2.1.0 --repo-output ../../repository/1.0.0 # Prompts: <YOUR REG + "/redis">

# metapackage (use same version for repo and metapackage) - init & release package
kctrl package init --chdir packages/metapackage # Prompts: metapackage.corp.com,1,config
kctrl package release --chdir packages/metapackage --version 1.0.0 --repo-output ../../repository/1.0.0 # Prompts: <YOUR REG + "/metapackage">

# Release repository (use same version for repo and metapackage)
kctrl package repository release --chdir repository/1.0.0 --version 1.0.0  # Prompts: app-repo.corp.com,<YOUR REG + "/app-repo">


