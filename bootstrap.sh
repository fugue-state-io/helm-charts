#!/bin/bash
export BOOTSTRAP_PATH=$(realpath "$0")
export WORKING_DIRECTORY=$(dirname $BOOTSTRAP_PATH)

helm install argo-cd ./argo-cd -n argocd && helm install fugue-state ./fugue-state -n argocd