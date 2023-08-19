#!/bin/bash
export BOOTSTRAP_PATH=$(realpath "$0")
export WORKING_DIRECTORY=$(dirname $BOOTSTRAP_PATH)

helm upgrade argo-cd ./argo-cd -n argocd && helm upgrade fugue-state ./fugue-state -n argocd