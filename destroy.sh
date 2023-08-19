#!/bin/bash
export BOOTSTRAP_PATH=$(realpath "$0")
export WORKING_DIRECTORY=$(dirname $BOOTSTRAP_PATH)

kubectl get Application -A -o name | xargs kubectl patch -p '{"metadata":{"finalizers":null}}' --type=merge -n argo-cd