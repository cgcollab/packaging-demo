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

##----HELLO_APP
## hello-app - build app container
[[ -d tmp/src/hello-app ]] || git clone https://github.com/cgcollab/hello-app tmp/src/hello-app
myDest=$MY_REG/hello-app yq e -i 'select(.kind == "Config").destinations[0].newImage = env(myDest)' tmp/src/hello-app/kbld.yml
#yq eval -i 'select(.kind == "Config").destinations[0].tags += ["1.2.3"] | select(.kind == "Config").destinations[0].tags = (select(.kind == "Config").destinations[0].tags | unique)' tmp/src/hello-app/kbld.yml
pushd tmp/src/hello-app && kbld -f kbld.yml -f manifest.lock --lock-output manifest.lock && popd
