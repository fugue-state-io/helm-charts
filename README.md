# fugue-state/helm-charts
Holds declarative deployments for all fugue-state services.
Deployed automatically by gitops.

argo-events:
  Contains events, eventbus, service accounts and CRDs

argo-cd:
  Contains CRDs for project, applications and starts argo-server.

argo-workflows:
  https://argoproj.github.io/argo-workflows/quick-start/

ci:
  contains bindings for argo-events and argo-workflows CRDs to create a ci pipeline.
