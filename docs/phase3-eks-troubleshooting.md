# Phase 3 EKS Troubleshooting Notes

## Issue

During Phase 3, the EKS managed node group failed to create successfully.

Terraform returned:

```text
NodeCreationFailure: Instances failed to join the kubernetes cluster
```

The EC2 worker nodes launched, but they did not register with the EKS cluster.

## Investigation

The following checks were performed:

```powershell
aws eks describe-nodegroup
kubectl get nodes
kubectl get configmap aws-auth -n kube-system -o yaml
aws iam list-attached-role-policies
aws ec2 get-console-output
```

The node IAM role was correctly mapped in both EKS access entries and the `aws-auth` ConfigMap. The node role also had the required EKS worker, CNI, ECR, and SSM policies.

The EC2 console output showed that `nodeadm` failed while parsing the custom Amazon Linux 2023 EKS node user data.

## Root Cause

The custom Packer-built EKS node AMI used Amazon Linux 2023, which relies on `nodeadm` for bootstrap configuration.

The node group used a custom AMI through a launch template, so the required node bootstrap configuration had to be supplied through user data.

The original user data formatting was invalid, which prevented `nodeadm` from loading the node configuration.

## Fix

The failed node group was deleted, the failed Terraform state entry was removed, and the node user data was simplified to valid `nodeadm` YAML:

```yaml
---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${cluster_name}
    apiServerEndpoint: ${cluster_endpoint}
    certificateAuthority: ${cluster_ca}
    cidr: ${cluster_service_cidr}
```

After applying the corrected configuration, the EKS managed node group reached `ACTIVE`.

## Result

The nodes successfully joined the Kubernetes cluster:

```powershell
kubectl get nodes
```

Result:

```text
2 nodes Ready
```

System pods also ran successfully:

```powershell
kubectl get pods -A
```

## Lessons Learned

* EC2 instances can launch successfully while still failing to join EKS.
* `NodeCreationFailure` can be caused by bootstrap configuration, not just IAM or networking.
* Amazon Linux 2023 EKS nodes use `nodeadm`.
* Custom EKS AMIs require valid user data when used with launch templates.
* EC2 console output is useful for diagnosing early node bootstrap failures.

