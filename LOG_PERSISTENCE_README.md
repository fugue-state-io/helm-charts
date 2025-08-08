# Log Persistence Setup - Complete Configuration

This setup provides centralized logging for the fugue-state.io platform, collecting logs from Kubernetes pods and storing them in S3 (DigitalOcean Spaces) for long-term retention and analysis.

## Components

1. **S3 Bucket**: `fugue-state-logs` bucket for storing log files (Terraform-managed)
2. **Fluent Bit DaemonSet**: Collects, parses, and forwards logs to S3  
3. **Structured Logging**: fugue-state-ui configured for JSON structured logging
4. **ArgoCD Application**: Auto-deployed via app-of-apps pattern

## Architecture

```
[fugue-state-ui pods] --> [Fluent Bit] --> [S3: fugue-state-logs]
                              ^
                              |
                     [K8s Secret: credentials] <-- [Terraform]
```

## What's Configured

### ✅ Terraform (Infrastructure)
- **S3 Bucket**: `fugue-state-logs` with 90-day lifecycle policy
- **Kubernetes Secret**: `log-persistence-s3-credentials` in `log-persistence` namespace
- **Namespace**: Dedicated `log-persistence` namespace with Linkerd service mesh injection
- **Credentials**: Uses existing `do_spaces_access_id` and `do_spaces_secret_key` variables

### ✅ Log Persistence Helm Chart
- **Fluent Bit DaemonSet**: Version pinned to 4.0.7 (latest stable)
- **Dedicated Namespace**: Runs in isolated `log-persistence` namespace
- **Namespace Coverage**: Collects from `default`, `fugue-state`, and `ui` namespaces  
- **JSON Parsing**: Configured specifically for fugue-state-ui structured logs
- **S3 Integration**: Uses Terraform-managed credentials via existing secret
- **Security**: Non-root, read-only filesystem, minimal RBAC permissions

### ✅ fugue-state-ui Updates
- **Environment Variables**: Added logging configuration to deployment
- **Pod Annotations**: Fluent Bit parser hints for optimal log processing
- **Structured Logging**: JSON format enabled via `LOG_STRUCTURED=true`
- **Log Levels**: Configurable per module via `LOG_LEVEL`

### ✅ ArgoCD Integration
- **Application**: `log-persistence-application.yaml` added to fugue-state chart
- **Auto-Sync**: Enabled with prune and self-heal
- **Ignore Differences**: Secret managed by Terraform, not ArgoCD
- **Image Updates**: Fluent Bit auto-updates within 4.x.x series (semver strategy)
- **Deployment Target**: Dedicated `log-persistence` namespace

## Deployment Flow

1. **Terraform Apply**: Creates S3 bucket and credentials secret
2. **ArgoCD Sync**: Detects new log-persistence application and deploys it
3. **Fluent Bit**: Starts collecting logs from all configured namespaces
4. **fugue-state-ui**: Outputs structured JSON logs when updated

## Log Structure in S3

```
s3://fugue-state-logs/
├── logs/
│   ├── 2024/08/08/
│   │   ├── ui/
│   │   │   ├── 20240808_143022_uuid.gz  # fugue-state-ui logs
│   │   ├── default/
│   │   │   ├── 20240808_143025_uuid.gz  # other pod logs
```

## Structured Log Format

When `LOG_STRUCTURED=true`, fugue-state-ui outputs:

```json
{
  "timestamp": "2024-08-08T14:30:22.123Z",
  "level": "INFO", 
  "module": "api/auth",
  "message": "User login successful",
  "context": {
    "userId": "usr***def",
    "ip": "10.0.0.1",
    "duration": 245
  }
}
```

## Environment Variables (fugue-state-ui)

These are automatically set by the Helm chart:

- `LOG_STRUCTURED=true` - Enable JSON structured logging
- `LOG_LEVEL=INFO` - Default log level
- `LOG_REQUEST_ENABLED=true` - HTTP request/response logging  
- `LOG_SECURITY_ENABLED=true` - Authentication/security event logging

## Monitoring & Operations

### Check Log Collection Status
```bash
# View Fluent Bit pods
kubectl get daemonset -n ui log-persistence

# Check Fluent Bit logs
kubectl logs -n ui -l app.kubernetes.io/name=log-persistence -f

# Verify S3 uploads
aws s3 ls s3://fugue-state-logs/logs/ --recursive --endpoint-url=https://nyc3.digitaloceanspaces.com
```

### Application Logs
```bash
# View fugue-state-ui structured logs
kubectl logs -n ui -l app.kubernetes.io/name=fugue-state-ui --tail=100

# Should show JSON format like:
# {"timestamp":"2024-08-08T14:30:22.123Z","level":"INFO","module":"api/auth","message":"Request started",...}
```

## Security & Retention

- **Credentials**: Managed by Terraform, stored as K8s secrets
- **Data Sanitization**: Sensitive fields automatically masked in logs
- **Retention**: 90 days via S3 lifecycle policy
- **Compression**: All logs gzipped before storage
- **Access**: IAM-based S3 permissions only

## Recent Changes (Version 4.0.7 Update)

### 🔄 Version Pin & Namespace Isolation
- **Fluent Bit**: Updated from 3.1.7 to 4.0.7 (latest stable release)
- **Dedicated Namespace**: Moved from `ui` to `log-persistence` namespace for better isolation
- **Auto-Updates**: Configured ArgoCD Image Updater to keep Fluent Bit within 4.x.x series
- **Terraform Update**: Added new `log-persistence` namespace with Linkerd injection
- **Secret Management**: Updated secret location to new namespace

### 🛡️ Security & Stability Benefits
- **Latest Features**: Access to latest Fluent Bit improvements and security patches
- **Namespace Isolation**: Log collection infrastructure separated from application workloads
- **Automated Updates**: Stay current with patch releases while maintaining stability
- **Service Mesh**: Fluent Bit pods now participate in Linkerd service mesh

## Next Steps

1. **Deploy Infrastructure**: `terraform apply` (creates bucket + credentials)
2. **ArgoCD Sync**: Will automatically detect and deploy log-persistence
3. **Update fugue-state-ui**: Redeploy to enable structured logging
4. **Monitor**: Verify logs appearing in S3 within 10-30 seconds

The system is fully configured and will auto-deploy via ArgoCD once Terraform changes are applied! 🚀
