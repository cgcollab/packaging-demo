#!/usr/bin/env bash

# Flow to create a new release for existing package:
#  Change the version in vendir.yaml then re-run kctrl commands with "-y" flag
#  Can also run "vendr sync" instead of "kctrl package init..." - same effect

kctrl package init --chdir packages/hello-app -y
kctrl package release --chdir packages/hello-app --version 1.2.3 --repo-output ../../repository/1.0.0  -y

kctrl package init --chdir packages/redis  -y
kctrl package release --chdir packages/redis --version 2.1.0 --repo-output ../../repository/1.0.0  -y

kctrl package init --chdir packages/metapackage  -y
kctrl package release --chdir packages/metapackage --version 1.0.0 --repo-output ../../repository/1.0.0  -y

kctrl package repository release --chdir repository/1.0.0 --version 1.0.0  -y






