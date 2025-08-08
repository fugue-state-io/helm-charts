# FUGUE-STATE-IO - helm charts 
==============
This helm charts repo contains the declarative specification for fugue-state.io it is managed by ARGOCD at https://argocd.fugue-state.io

## Charts

### Application Charts
- **fugue-state-ui**: Main web application frontend
- **fugue-state**: Backend API services  
- **keycloak**: Identity and access management
- **jump**: Development jump server

### Infrastructure Charts
- **cert-manager**: SSL certificate management
- **cert-issuer**: Certificate issuer configuration
- **reloader**: Automatic pod restarts on config changes
- **redis**: In-memory data store
- **log-persistence**: Centralized logging with S3 storage

### Processing Charts  
- **airflow**: Workflow orchestration
- **argo-cd**: GitOps continuous deployment
- **argo-events**: Event-driven workflow automation
- **argo-workflows**: Container-native workflow engine
- **argocd-image-updater**: Automatic image updates
- **processing**: Data processing pipelines
- **workflows**: Custom workflow definitions

## Log Persistence

The log-persistence chart provides centralized logging using Fluent Bit to collect logs from all pods and forward them to S3-compatible storage (DigitalOcean Spaces).

### Features
- Automatic log collection from Kubernetes pods
- Structured JSON log parsing for fugue-state-ui  
- S3 storage with automatic retention (90 days)
- Kubernetes metadata enrichment
- Security log filtering and sanitization
- Monitoring and health check endpoints

### Quick Setup
```bash
# Deploy log collection
helm install log-persistence ./log-persistence \
  --set s3.accessKeyId="YOUR_ACCESS_KEY" \
  --set s3.secretAccessKey="YOUR_SECRET_KEY"

# Enable structured logging in fugue-state-ui
helm upgrade fugue-state-ui ./fugue-state-ui \
  --set logging.structured=true
```

See [log-persistence/DEPLOYMENT.md](log-persistence/DEPLOYMENT.md) for detailed deployment instructions.