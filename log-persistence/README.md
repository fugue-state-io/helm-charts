# Log Persistence Helm Chart

A Helm chart for deploying Fluent Bit log collection and forwarding to S3-compatible storage.

## Description

This chart deploys Fluent Bit as a DaemonSet to collect logs from Kubernetes pods and forward them to S3-compatible storage (DigitalOcean Spaces). It includes:

- Fluent Bit DaemonSet for log collection
- ConfigMap with Fluent Bit configuration
- RBAC resources for Kubernetes API access
- Secret management for S3 credentials
- Service for monitoring endpoints

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- S3-compatible storage bucket (DigitalOcean Spaces)
- Valid S3 access credentials

## Installation

```bash
# Add S3 credentials
helm install log-persistence ./log-persistence \
  --set s3.accessKeyId="YOUR_ACCESS_KEY" \
  --set s3.secretAccessKey="YOUR_SECRET_KEY"
```

## Configuration

The following table lists the configurable parameters and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `fluentbit.image.repository` | Fluent Bit image repository | `fluent/fluent-bit` |
| `fluentbit.image.tag` | Fluent Bit image tag | `3.1.7` |
| `fluentbit.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `fluentbit.resources.limits.cpu` | CPU limit | `200m` |
| `fluentbit.resources.limits.memory` | Memory limit | `256Mi` |
| `fluentbit.resources.requests.cpu` | CPU request | `100m` |
| `fluentbit.resources.requests.memory` | Memory request | `128Mi` |
| `s3.endpoint` | S3 endpoint URL | `https://nyc3.digitaloceanspaces.com` |
| `s3.bucket` | S3 bucket name | `fugue-state-logs` |
| `s3.region` | S3 region | `nyc3` |
| `s3.pathPrefix` | Path prefix for logs | `logs` |
| `s3.accessKeyId` | S3 access key ID | `""` (required) |
| `s3.secretAccessKey` | S3 secret access key | `""` (required) |
| `logging.namespaces` | Namespaces to collect logs from | `[default, fugue-state]` |
| `logging.parsing.enabled` | Enable log parsing | `true` |
| `logging.parsing.json` | Parse JSON logs | `true` |
| `logging.enrichment.enabled` | Enable Kubernetes metadata enrichment | `true` |
| `monitoring.enabled` | Enable monitoring endpoints | `true` |
| `monitoring.metricsPort` | Metrics endpoint port | `2020` |
| `monitoring.healthPort` | Health check endpoint port | `2021` |
| `buffering.bufferSize` | Buffer size for logs | `64KB` |
| `buffering.flushInterval` | Flush interval in seconds | `10` |
| `buffering.maxRetries` | Maximum retries for failed uploads | `3` |

## S3 Path Structure

Logs are stored with the following path structure:
```
s3://bucket/logs/YYYY/MM/DD/namespace/YYYYMMDD_HHMMSS_UUID.gz
```

Example:
```
s3://fugue-state-logs/logs/2024/01/15/fugue-state-ui/20240115_120000_abc123.gz
```

## Log Format

Collected logs include Kubernetes metadata and are optionally parsed as JSON:

```json
{
  "log": "original log message",
  "time": "2024-01-15T12:00:00.000Z",
  "kubernetes": {
    "pod_name": "fugue-state-ui-12345",
    "namespace_name": "default",
    "container_name": "fugue-state-ui",
    "labels": {
      "app.kubernetes.io/name": "fugue-state-ui"
    }
  }
}
```

## Monitoring

When monitoring is enabled, Fluent Bit exposes:

- Metrics endpoint: `http://pod:2020/api/v1/metrics/prometheus`
- Health endpoint: `http://pod:2021/api/v1/health`

## RBAC

The chart creates minimal RBAC permissions:

- ServiceAccount for Fluent Bit pods
- ClusterRole with read access to:
  - namespaces
  - pods
  - pods/logs
- ClusterRoleBinding to associate the role with the service account

## Security

- Runs as non-root user (UID 1000)
- Read-only root filesystem
- Drops all capabilities
- S3 credentials stored as Kubernetes secrets
- Log sanitization removes sensitive data

## Troubleshooting

### Logs not appearing in S3

1. Check Fluent Bit pod logs:
   ```bash
   kubectl logs -l app.kubernetes.io/name=log-persistence
   ```

2. Verify S3 credentials:
   ```bash
   kubectl get secret log-persistence-s3-credentials -o yaml
   ```

3. Check network connectivity:
   ```bash
   kubectl exec -it <fluent-bit-pod> -- wget -O- https://nyc3.digitaloceanspaces.com
   ```

### High resource usage

1. Reduce flush interval to process logs more frequently
2. Limit buffer size to control memory usage
3. Filter logs from unnecessary namespaces

### Missing log metadata

Ensure the service account has proper RBAC permissions to read Kubernetes metadata.

## Upgrade

To upgrade the chart:

```bash
helm upgrade log-persistence ./log-persistence
```

## Uninstall

To uninstall/delete the deployment:

```bash
helm uninstall log-persistence
```

This will remove all Kubernetes resources but preserve the S3 bucket and stored logs.
