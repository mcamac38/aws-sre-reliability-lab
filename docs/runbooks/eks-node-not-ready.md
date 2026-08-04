# Runbook: EKS Node Not Ready

## Purpose

Use this runbook when one or more EKS worker nodes are not `Ready`, or when the EKS node group reports health issues.

## Symptoms

* `kubectl get nodes` shows a node as `NotReady`.
* Pods remain `Pending`.
* CloudWatch alarm `sre-lab-phase3-eks-failed-nodes` enters `ALARM`.
* EKS node group reports health issues.

## Quick Checks

```powershell
kubectl get nodes -o wide
kubectl get pods -A -o wide
```

Check the managed node group:

```powershell
aws eks describe-nodegroup `
  --cluster-name sre-lab-phase3-eks-cluster `
  --nodegroup-name sre-lab-phase3-eks-nodes `
  --profile terraform_learn `
  --region us-east-2 `
  --query "nodegroup.{Status:status,HealthIssues:health.issues,Scaling:scalingConfig}" `
  --output json
```

## Investigation Steps

### 1. Describe the node

```powershell
kubectl describe node <node-name>
```

Look for:

* MemoryPressure
* DiskPressure
* PIDPressure
* NetworkUnavailable
* KubeletNotReady

### 2. Check system pods

```powershell
kubectl get pods -n kube-system -o wide
```

Important pods:

* `aws-node`
* `coredns`
* `kube-proxy`

### 3. Check EC2 instances

```powershell
aws ec2 describe-instances `
  --profile terraform_learn `
  --region us-east-2 `
  --filters "Name=tag:eks:nodegroup-name,Values=sre-lab-phase3-eks-nodes" `
  --query "Reservations[*].Instances[*].[InstanceId,ImageId,State.Name,PrivateIpAddress,SubnetId]" `
  --output table
```

### 4. Check node group health

```powershell
aws eks describe-nodegroup `
  --cluster-name sre-lab-phase3-eks-cluster `
  --nodegroup-name sre-lab-phase3-eks-nodes `
  --profile terraform_learn `
  --region us-east-2 `
  --query "nodegroup.health.issues" `
  --output json
```

## Common Causes

| Symptom                    | Likely Cause                                  |
| -------------------------- | --------------------------------------------- |
| Node `NotReady`            | Kubelet or node networking issue              |
| Pods stuck `Pending`       | Not enough capacity or node scheduling issue  |
| Node group `CREATE_FAILED` | Node bootstrap, IAM, networking, or AMI issue |
| `aws-node` not running     | VPC CNI issue                                 |

## Recovery Steps

### Recheck node group desired capacity

```powershell
aws eks describe-nodegroup `
  --cluster-name sre-lab-phase3-eks-cluster `
  --nodegroup-name sre-lab-phase3-eks-nodes `
  --profile terraform_learn `
  --region us-east-2 `
  --query "nodegroup.scalingConfig" `
  --output json
```

Expected lab configuration:

```text
desiredSize: 2
minSize: 2
maxSize: 3
```

### Restart affected application pods after node recovery

```powershell
kubectl rollout restart deployment/sre-ecs-web -n sre-lab
kubectl rollout status deployment/sre-ecs-web -n sre-lab
```

### Verify final state

```powershell
kubectl get nodes
kubectl get deployment -n sre-lab
kubectl get pods -n sre-lab -o wide
```

Expected result:

```text
2 nodes Ready
deployment 2/2
pods Running
```

## Notes

For custom Packer-built AL2023 EKS node AMIs, node bootstrap depends on valid `nodeadm` user data. If a node group fails during creation, capture EC2 console output before deleting the failed instances.
