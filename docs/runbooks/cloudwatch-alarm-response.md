# Runbook: CloudWatch Alarm Response

## Purpose

Use this runbook when a Phase 4 CloudWatch alarm enters `ALARM` or `INSUFFICIENT_DATA`.

## Current Alarms

```text
sre-lab-phase3-eks-node-cpu-high
sre-lab-phase3-eks-node-memory-high
sre-lab-phase3-eks-failed-nodes
sre-lab-phase3-eks-failed-app-pods
```

## Quick Checks

List alarm states:

```powershell
aws cloudwatch describe-alarms `
  --profile terraform_learn `
  --region us-east-2 `
  --alarm-name-prefix "sre-lab-phase3-eks" `
  --query "MetricAlarms[*].[AlarmName,StateValue,MetricName,Namespace]" `
  --output table
```

Check Kubernetes health:

```powershell
kubectl get nodes
kubectl get deployment -n sre-lab
kubectl get pods -n sre-lab -o wide
```

## Alarm Response

### Node CPU High

Alarm:

```text
sre-lab-phase3-eks-node-cpu-high
```

Check node and pod usage:

```powershell
kubectl get nodes
kubectl top nodes
kubectl top pods -n sre-lab
```

Check app health:

```powershell
kubectl get deployment -n sre-lab
kubectl get pods -n sre-lab
```

Possible actions:

* Confirm whether traffic/load increased.
* Check for runaway pods.
* Consider scaling pods or nodes if pressure continues.

### Node Memory High

Alarm:

```text
sre-lab-phase3-eks-node-memory-high
```

Check memory usage:

```powershell
kubectl top nodes
kubectl top pods -A
```

Possible actions:

* Check for memory-heavy pods.
* Review pod memory requests and limits.
* Restart unhealthy pods only if needed.

### Failed Nodes

Alarm:

```text
sre-lab-phase3-eks-failed-nodes
```

Check node health:

```powershell
kubectl get nodes -o wide
kubectl describe nodes
```

Check EKS node group:

```powershell
aws eks describe-nodegroup `
  --cluster-name sre-lab-phase3-eks-cluster `
  --nodegroup-name sre-lab-phase3-eks-nodes `
  --profile terraform_learn `
  --region us-east-2 `
  --query "nodegroup.{Status:status,HealthIssues:health.issues}" `
  --output json
```

### Failed App Pods

Alarm:

```text
sre-lab-phase3-eks-failed-app-pods
```

Check pods:

```powershell
kubectl get pods -n sre-lab -o wide
kubectl describe pods -n sre-lab
kubectl get events -n sre-lab --sort-by=.lastTimestamp
```

Check logs:

```powershell
kubectl logs deployment/sre-ecs-web -n sre-lab
```

## INSUFFICIENT_DATA

If an alarm is in `INSUFFICIENT_DATA`, check whether the metric exists:

```powershell
aws cloudwatch list-metrics `
  --namespace ContainerInsights `
  --profile terraform_learn `
  --region us-east-2 `
  --dimensions Name=ClusterName,Value=sre-lab-phase3-eks-cluster
```

Possible causes:

* CloudWatch add-on is not running.
* Metrics have not arrived yet.
* Metric dimension does not match the alarm.
* Cluster or workload is not producing the expected metric.

## Recovery Validation

After any action, confirm:

```powershell
kubectl get nodes
kubectl get deployment -n sre-lab
kubectl get pods -n sre-lab
aws cloudwatch describe-alarms `
  --profile terraform_learn `
  --region us-east-2 `
  --alarm-name-prefix "sre-lab-phase3-eks" `
  --query "MetricAlarms[*].[AlarmName,StateValue]" `
  --output table
```

Expected final state:

```text
Nodes Ready
Deployment 2/2
Pods Running
Alarms OK
```
