#!/usr/bin/env bash

if [[ $(basename $(pwd)) == "scripts" ]]; then cd .. && echo "PWD=$(pwd)"; fi

rm -rf tmp/

rm -rf repositories/1.0.0/packages
rm -f repositories/1.0.0/package-repository.yml
rm -f repositories/1.0.0/pkgrepo-build.yml
echo '' > repositories/1.0.0/.gitkeep

rm -rf repositories/1.0.0-small/packages
rm -f repositories/1.0.0-small/package-repository.yml
rm -f repositories/1.0.0-small/pkgrepo-build.yml
echo '' > repositories/1.0.0-small/.gitkeep

rm -rf packages/metapackage/carvel-artifacts
rm -f packages/metapackage/package-build.yml
rm -f packages/metapackage/package-resources.yml

rm -rf packages/giant-app/carvel-artifacts
rm -f packages/giant-app/package-build.yml
rm -f packages/giant-app/package-resources.yml

rm -rf packages/hello-app/carvel-artifacts
rm -f packages/hello-app/package-build.yml
rm -f packages/hello-app/package-resources.yml

rm -rf packages/hello-redis/carvel-artifacts
rm -rf packages/hello-redis/upstream
rm -f packages/hello-redis/package-build.yml
rm -f packages/hello-redis/package-resources.yml
rm -f packages/hello-redis/vendir.yml
rm -f packages/hello-redis/vendir.lock.yml
