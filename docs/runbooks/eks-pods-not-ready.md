# Runbook: EKS Application Pods Not Ready

## Purpose

Use this runbook when the Flask application pods in the `sre-lab` namespace are not `Running` or not `Ready`.

## Symptoms

* Pods show `Pending`, `CrashLoopBackOff`, `ImagePullBackOff`, or `0/1 Ready`.
* Deployment does not show `2/2` available replicas.
* The application fails the port-forward test.

## Quick Checks

```powershell
kubectl get deployment -n sre-lab
kubectl get pods -n sre-lab -o wide
kubectl get service -n sre-lab
```

Expected healthy state:

```text
deployment.apps/sre-ecs-web   2/2
pods                           Running
service                        ClusterIP
```

## Investigation Steps

### 1. Describe the affected pod

```powershell
kubectl describe pod <pod-name> -n sre-lab
```

Check the Events section for scheduling, image pull, probe, or container startup errors.

### 2. Check pod logs

```powershell
kubectl logs <pod-name> -n sre-lab
```

If the pod restarted, check previous logs:

```powershell
kubectl logs <pod-name> -n sre-lab --previous
```

### 3. Check the deployment

```powershell
kubectl describe deployment sre-ecs-web -n sre-lab
```

Confirm:

* Desired replicas: `2`
* Available replicas: `2`
* Image: `728121070699.dkr.ecr.us-east-2.amazonaws.com/sre-ecs-web:v1`

### 4. Check recent namespace events

```powershell
kubectl get events -n sre-lab --sort-by=.lastTimestamp
```

## Common Causes

| Symptom            | Likely Cause                                            |
| ------------------ | ------------------------------------------------------- |
| `ImagePullBackOff` | ECR image tag missing or node role cannot pull from ECR |
| `CrashLoopBackOff` | Application starts and exits repeatedly                 |
| `0/1 Ready`        | Readiness probe is failing                              |
| `Pending`          | Not enough node capacity or scheduling issue            |

## Recovery Steps

### Restart the deployment

```powershell
kubectl rollout restart deployment/sre-ecs-web -n sre-lab
kubectl rollout status deployment/sre-ecs-web -n sre-lab
```

### Reapply the manifest

```powershell
kubectl apply -f kubernetes\phase3-eks\flask-app.yaml
```

### Verify recovery

```powershell
kubectl get deployment -n sre-lab
kubectl get pods -n sre-lab -o wide
```

Expected result:

```text
sre-ecs-web   2/2
```

## Escalation

If pods still do not become ready, check:

```powershell
kubectl describe nodes
kubectl get pods -A
aws cloudwatch describe-alarms --profile terraform_learn --region us-east-2
```
