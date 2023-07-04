kubectl get Application -A -o name | xargs kubectl patch -p '{"metadata":{"finalizers":null}}' --type=merge -n argocd
