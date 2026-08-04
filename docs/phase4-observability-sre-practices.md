# Phase 4 Observability and SRE Practices

## Summary

Phase 4 added observability and SRE practices to the EKS-based application deployed in Phase 3.

The goal was to improve visibility into the EKS cluster, worker nodes, application pods, and operational failure scenarios. This phase added EKS control plane logging, CloudWatch observability, CloudWatch alarms, operational runbooks, and Kubernetes autoscaling with the Horizontal Pod Autoscaler.

## Architecture

```text
Amazon EKS Cluster
    ↓
EKS Control Plane Logs
    ↓
CloudWatch Logs

EKS Worker Nodes
    ↓
CloudWatch Observability Add-on
    ↓
Container Insights Metrics and Logs

Flask Application Pods
    ↓
Kubernetes Deployment and Service
    ↓
CloudWatch Alarms and HPA
```

## Tools Used

* Amazon EKS
* Amazon CloudWatch
* CloudWatch Logs
* CloudWatch Container Insights
* CloudWatch Observability EKS Add-on
* Kubernetes Metrics Server
* Kubernetes Horizontal Pod Autoscaler
* Terraform
* kubectl
* AWS CLI
* Windows PowerShell

## Phase 4A: EKS Control Plane Logging

EKS control plane logging was enabled for the cluster:

```text
sre-lab-phase3-eks-cluster
```

The following log types were enabled:

```text
api
audit
authenticator
controllerManager
scheduler
```

A CloudWatch log group was created and managed with Terraform:

```text
/aws/eks/sre-lab-phase3-eks-cluster/cluster
```

The log retention period was set to:

```text
7 days
```

This provides visibility into Kubernetes API activity, authentication activity, audit events, scheduling behavior, and controller activity.

## Phase 4B: CloudWatch Observability Add-on

The Amazon CloudWatch Observability EKS add-on was installed with Terraform.

Add-on:

```text
amazon-cloudwatch-observability
```

The add-on reached:

```text
ACTIVE
```

Verified version:

```text
v6.2.0-eksbuild.1
```

This enabled EKS workload and infrastructure observability through CloudWatch and Container Insights.

## Phase 4C: CloudWatch Alarms

CloudWatch alarms were added for EKS node-level and pod-level health metrics.

Alarms created:

```text
sre-lab-phase3-eks-node-cpu-high
sre-lab-phase3-eks-node-memory-high
sre-lab-phase3-eks-failed-nodes
sre-lab-phase3-eks-failed-app-pods
```

The alarms monitor Container Insights metrics for:

* Node CPU utilization
* Node memory utilization
* Failed node count
* Failed application pod count

All alarms were verified in CloudWatch and reached:

```text
OK
```

## Phase 4D: SRE Runbooks

Operational runbooks were created under:

```text
docs/runbooks
```

Runbooks added:

```text
eks-pods-not-ready.md
eks-node-not-ready.md
cloudwatch-alarm-response.md
```

These runbooks provide repeatable troubleshooting steps for common EKS and application incidents.

The runbooks cover:

* Application pods not ready
* EKS nodes not ready
* CloudWatch alarm response
* Common investigation commands
* Recovery validation steps

## Phase 4E: HPA and Load Test

Kubernetes Metrics Server was installed to provide resource metrics for the Horizontal Pod Autoscaler.

The HPA manifest was created under:

```text
kubernetes/phase4-observability/hpa.yaml
```

The HPA was configured for the Flask application deployment:

```text
Deployment: sre-ecs-web
Namespace: sre-lab
Minimum replicas: 2
Maximum replicas: 4
CPU target: 30%
```

A load test was performed using temporary BusyBox load generator pods.

During the test:

* Load was sent to the internal Kubernetes service.
* HPA detected increased CPU utilization.
* The Flask application scaled up under load.
* Load generator pods were removed.
* The application returned toward the baseline replica count.

## Verification Commands

Control plane logging was verified with:

```powershell
aws eks describe-cluster `
  --name sre-lab-phase3-eks-cluster `
  --profile terraform_learn `
  --region us-east-2 `
  --query "cluster.logging.clusterLogging" `
  --output json
```

CloudWatch alarms were verified with:

```powershell
aws cloudwatch describe-alarms `
  --profile terraform_learn `
  --region us-east-2 `
  --alarm-name-prefix "sre-lab-phase3-eks" `
  --query "MetricAlarms[*].[AlarmName,StateValue,MetricName,Namespace]" `
  --output table
```

Kubernetes health was verified with:

```powershell
kubectl get nodes
kubectl get deployment -n sre-lab
kubectl get pods -n sre-lab
kubectl get hpa -n sre-lab
```

Application access was previously verified with:

```powershell
kubectl port-forward -n sre-lab service/sre-ecs-web-service 8080:80
Invoke-WebRequest http://localhost:8080
```

Result:

```text
StatusCode: 200
```

## Final Result

Phase 4 successfully added observability and SRE practices to the EKS application environment.

Final capabilities include:

* EKS control plane logging
* CloudWatch log retention
* CloudWatch Observability EKS add-on
* Container Insights metrics
* CloudWatch alarms for EKS health
* SRE runbooks
* Kubernetes Metrics Server
* Horizontal Pod Autoscaler
* Load testing and autoscaling validation

## Phase 4 Status

```text
Phase 4A — EKS control plane logging: complete
Phase 4B — CloudWatch Observability add-on: complete
Phase 4C — CloudWatch alarms: complete
Phase 4D — SRE runbooks: complete
Phase 4E — HPA and load test: complete
Phase 4F — Phase 4 documentation: complete
```
