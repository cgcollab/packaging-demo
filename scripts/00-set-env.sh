#!/usr/bin/env bash

(return 0 2>/dev/null) || echo "RECOMMENDATION: *Source* this script to set env between executions"

if [ -z $MY_REG ]; then
  echo "Enter your registry: " && read MY_REG && export MY_REG;
fi

echo -e "\nMY_REG=$MY_REG"
