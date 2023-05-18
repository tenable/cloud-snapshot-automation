#!/bin/bash

ROOT="./output"

for d in ${ROOT}/* ; do
  if [ -d "${d}" ]; then
    echo "Initializing ${d}"
    terraform -chdir="${d}" init --upgrade
    terraform -chdir="${d}" apply
  fi
done