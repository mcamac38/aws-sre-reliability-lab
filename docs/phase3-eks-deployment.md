# Phase 3 EKS Deployment

## Summary

Phase 3 expanded the AWS SRE reliability lab from ECS/Fargate into Kubernetes using Amazon EKS.

The goal was to provision an EKS environment with Terraform, build a custom EKS worker node AMI with Packer, deploy the existing Flask application to Kubernetes, and validate basic failure recovery behavior.

## Architecture

```text
User / Local Machine
    ↓
kubectl
    ↓
Amazon EKS Cluster
    ↓
EKS Managed Node Group
    ↓
Packer-built Amazon Linux 2023 EKS Worker Nodes
    ↓
Kubernetes Deployment
    ↓
Flask Application Pods
    ↓
Kubernetes ClusterIP Service
```

## Tools Used

* Terraform
* Packer
* Amazon EKS
* Amazon EC2
* Amazon ECR
* Kubernetes
* kubectl
* AWS CLI
* Windows PowerShell

## Phase 3A: Terraform EKS Environment

A new Terraform environment was created under:

```text
terraform/environments/phase3-eks
```

This environment was separated from the previous ECS environment to keep the EKS work isolated and easier to manage.

## Phase 3B: Packer Custom EKS Node AMI

Packer was added to the project to build a custom EKS worker node AMI.

The Packer configuration was created under:

```text
packer/eks-node-ami
```

The custom AMI was based on an EKS-optimized Amazon Linux 2023 image and included additional troubleshooting and operations tools.

The final Packer-built AMI used by the node group was:

```text
ami-07d90c8c77268bef6
```

## Phase 3C: EKS Networking Foundation

Terraform created the networking foundation for EKS, including:

* VPC
* Public subnets
* Private subnets
* Internet Gateway
* NAT Gateway
* Route tables
* EKS subnet tags

The worker nodes were placed in private subnets, while the NAT Gateway allowed outbound access for package updates, AWS APIs, and container image pulls.

## Phase 3D: EKS Control Plane

Terraform created the EKS cluster control plane:

```text
sre-lab-phase3-eks-cluster
```

The cluster was configured with public and private endpoint access so it could be managed from the local machine while still supporting private VPC access.

## Phase 3E: EKS Managed Node Group

Terraform created an EKS managed node group using the custom Packer-built AMI through a launch template.

The node group name was:

```text
sre-lab-phase3-eks-nodes
```

After troubleshooting the AL2023 node bootstrap configuration, the node group reached:

```text
ACTIVE
```

The Kubernetes nodes successfully joined the cluster:

```text
2 nodes Ready
```

## Phase 3F: Kubernetes Access Verification

The local kubeconfig was updated using:

```powershell
aws eks update-kubeconfig `
  --name sre-lab-phase3-eks-cluster `
  --profile terraform_learn `
  --region us-east-2
```

The cluster was verified with:

```powershell
kubectl get nodes
kubectl get pods -A
```

Final result:

```text
2 EKS nodes Ready
aws-node Running
coredns Running
kube-proxy Running
```

## Phase 3G: Flask App Deployment to EKS

The existing Flask container image from Phase 2 was reused from Amazon ECR:

```text
728121070699.dkr.ecr.us-east-2.amazonaws.com/sre-ecs-web:v1
```

A Kubernetes manifest was created under:

```text
kubernetes/phase3-eks/flask-app.yaml
```

The manifest created:

* Namespace
* Deployment
* ClusterIP Service
* 2 application replicas
* Readiness probe
* Liveness probe
* CPU and memory requests/limits

The deployment reached:

```text
READY: 2/2
AVAILABLE: 2
```

## Application Test

The application was tested locally using Kubernetes port forwarding:

```powershell
kubectl port-forward -n sre-lab service/sre-ecs-web-service 8080:80
```

Then tested with:

```powershell
Invoke-WebRequest http://localhost:8080
```

Result:

```text
StatusCode: 200
```

## Phase 3H: Failure Recovery Test

A pod failure recovery test was performed by deleting one running Flask application pod.

Kubernetes automatically created a replacement pod through the Deployment and ReplicaSet controllers.

Final state:

```text
Deployment READY: 2/2
Pods Running: 2/2
```

The replacement pod was scheduled successfully, and the application returned to the desired replica count.

## Troubleshooting

During Phase 3, the EKS managed node group initially failed because the custom AL2023 node AMI user data was not formatted correctly for `nodeadm`.

Troubleshooting details are documented separately in:

```text
docs/phase-3-eks-troubleshooting.md
```

## Final Result

Phase 3 successfully deployed the Flask application to Amazon EKS using Terraform-managed infrastructure and a Packer-built custom worker node AMI.

The final environment included:

* EKS cluster
* Managed node group
* Custom Packer AMI
* Private worker nodes
* Kubernetes deployment
* Kubernetes service
* Healthy application pods
* Successful HTTP test
* Successful pod failure recovery test

## Phase 3 Status

```text
Phase 3A — Terraform EKS environment: complete
Phase 3B — Packer custom EKS node AMI: complete
Phase 3C — EKS networking foundation: complete
Phase 3D — EKS control plane: complete
Phase 3E — EKS managed node group: complete
Phase 3F — Kubernetes access verification: complete
Phase 3G — Flask app deployed to EKS: complete
Phase 3H — Pod failure recovery test: complete
```
