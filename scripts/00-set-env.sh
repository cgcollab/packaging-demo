#!/usr/bin/env bash

# taplab.azurecr.io/packaging-demo

if [[ $(basename $(pwd)) == "scripts" ]]; then cd .. && echo "PWD=$(pwd)"; fi

(return 0 2>/dev/null) || echo "RECOMMENDATION: *Source* this script to set env between executions"

if [ -z $MY_REG ]; then
  #echo "Enter your registry: " && read MY_REG && export MY_REG;
  export MY_REG=taplab.azurecr.io/packaging-demo
fi

echo -e "\nMY_REG=$MY_REG"
