#!/usr/bin/env bash

if [[ $(basename $(pwd)) == "scripts" ]]; then cd .. && echo "PWD=$(pwd)"; fi

# Flow to create a new release for existing package:
#  Change the version in vendir.yaml then re-run kctrl commands with "-y" flag
#  Can also run "vendir sync" instead of "kctrl package init..." - same effect

kctrl package init --chdir packages/hello-app -y
kctrl package release --chdir packages/hello-app --version 1.2.3 --repo-output ../../repositories/1.0.0  -y

kctrl package init --chdir packages/hello-redis  -y
kctrl package release --chdir packages/hello-redis --version 2.1.0 --repo-output ../../repositories/1.0.0  -y

kctrl package init --chdir packages/metapackage  -y
kctrl package release --chdir packages/metapackage --version 1.0.0 --repo-output ../../repositories/1.0.0  -y

kctrl package repository release --chdir repositories/1.0.0 --version 1.0.0  -y

# If package repo tag is the same, you can trigger immediate reconciliation (default is every 10 min)
# Otherwise, re-install (see scripts/install-metapackage.sh)
kctrl package repo kick --repository metapackage-repo -n metapackage-install -y
kctrl package installed kick --package-install my-metapackage -n metapackage-install -y

# kick other packages
kctrl package installed kick --package-install hello-app -n metapackage-install -y

# TROUBLESHOOTING
# In case of error, correct configuration errors and re-release corrected package, metapackage, and repo by re-running init commands with a "-y" flag
# See scripts/update-packages.sh

# To delete a package:
# kctrl p i delete -i my-metapackage -n metapackage-install
# If deletion gets stuck, in separate terminal, run:
# kctrl p i delete -i hello-redis -n metapackage-install --noop
# kctrl p i delete -i hello-app -n metapackage-install --noop


