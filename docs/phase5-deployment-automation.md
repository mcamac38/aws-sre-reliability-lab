# Phase 5 Deployment Automation and Recovery

## Summary

Phase 5 added deployment automation, release safety checks, rollback capability, and failure testing to the EKS-based application environment.

The goal was to move beyond manual deployment and demonstrate safer operational practices for managing Kubernetes workloads. This phase added a GitLab CI/CD validation pipeline, PowerShell automation scripts, Kubernetes release safety checks, rollback automation, and live failure testing against the EKS application.

## Phase 5 Goals

Phase 5 focused on four main areas:

```text
CI/CD
Release safety
Rollback
Failure testing
```

## Tools Used

* GitLab CI/CD syntax
* Terraform
* Kubernetes
* kubectl
* AWS CLI
* PowerShell
* Amazon EKS
* Amazon CloudWatch
* Packer

## Phase 5A: Phase 5 Branch

A dedicated Phase 5 branch was used for deployment automation work:

```text
phase-5-deployment-automation
```

This allowed the automation and recovery work to be developed separately from earlier infrastructure phases.

## Phase 5B: GitLab CI/CD Validation Pipeline

A GitLab CI/CD pipeline configuration was added:

```text
.gitlab-ci.yml
```

The pipeline was designed as a validation-only pipeline. It does not deploy infrastructure, modify AWS resources, or require AWS credentials.

The pipeline includes:

```text
Terraform validation
Kubernetes YAML validation
```

The Terraform validation job checks:

```text
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

The Kubernetes validation job checks Kubernetes manifest YAML syntax for the application and observability manifests.

This provides a safe CI/CD foundation because the pipeline validates code quality without applying infrastructure changes.

## Phase 5C: Deployment and Recovery Scripts

PowerShell scripts were added under:

```text
scripts/phase5
```

Scripts added:

```text
deploy-eks-app.ps1
verify-eks-health.ps1
recover-eks-app.ps1
rollback-eks-app.ps1
```

### deploy-eks-app.ps1

The deployment script automates application deployment to EKS.

It performs:

```text
AWS CLI and kubectl checks
kubeconfig update
kubectl context validation
manifest existence checks
client-side dry run
application manifest apply
HPA manifest apply
deployment rollout status check
post-deployment status checks
```

### verify-eks-health.ps1

The health verification script checks the current operational state of the EKS environment.

It verifies:

```text
EKS cluster status
Kubernetes nodes
kube-system pods
application deployment
application pods
application service
HPA status
CloudWatch alarms
```

### recover-eks-app.ps1

The recovery script provides a repeatable application recovery action.

It can:

```text
inspect deployment state
inspect pod state
optionally reapply the application manifest
restart the deployment
wait for rollout completion
verify final deployment and pod state
```

### rollback-eks-app.ps1

The rollback script provides a repeatable Kubernetes rollback action.

It can:

```text
show rollout history
inspect current deployment state
run kubectl rollout undo
wait for rollback completion
verify final deployment and pod state
```

## Phase 5D: Local Validation Testing

Before live testing, local validation checks were completed.

PowerShell script syntax was validated for:

```text
deploy-eks-app.ps1
verify-eks-health.ps1
recover-eks-app.ps1
rollback-eks-app.ps1
```

Terraform validation was completed successfully:

```text
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

Kubernetes YAML validation was also completed successfully.

## Phase 5E: Release Safety Checks

Release safety checks were added to the deployment script to reduce the risk of deploying to the wrong cluster or applying invalid manifests.

The deployment script now checks:

```text
Required commands are available
Manifest files exist
kubeconfig is updated for the expected EKS cluster
kubectl current context matches the expected cluster
Kubernetes manifests pass client-side dry run
Deployment rollout completes successfully
```

This helps prevent unsafe deployments and makes the deployment process more repeatable.

## Phase 5F: Rollback Automation

A rollback script was added:

```text
scripts/phase5/rollback-eks-app.ps1
```

The script uses Kubernetes native rollout history and rollback functionality:

```text
kubectl rollout history
kubectl rollout undo
kubectl rollout status
```

This provides a repeatable way to recover from a failed or bad application release.

## Phase 5G: Live Failure Testing

The EKS environment was recreated using Packer and Terraform so the automation and recovery process could be tested live.

The custom EKS node AMI had to be rebuilt with Packer before Terraform could recreate the EKS node group. After the AMI was rebuilt, Terraform successfully recreated the EKS environment.

During recreation, the EKS control plane log group already existed because EKS created it automatically. The log group was imported into Terraform state and the apply was completed successfully.

## Deployment Script Test

The deployment script was tested successfully:

```powershell
.\scripts\phase5\deploy-eks-app.ps1
```

The script completed:

```text
kubeconfig update
kubectl context safety check
manifest dry run
application deployment
HPA deployment
rollout status check
```

## Health Verification Test

The health verification script was tested successfully:

```powershell
.\scripts\phase5\verify-eks-health.ps1
```

The environment showed healthy EKS nodes, running application pods, an active service, HPA configuration, and CloudWatch alarm visibility.

## Pod Failure Recovery Test

A running application pod was manually deleted.

Kubernetes automatically created a replacement pod and returned the deployment to the desired replica count.

Result:

```text
Deleted pod was replaced
Deployment returned to READY 2/2
Application pods returned to Running
```

This confirmed Kubernetes self-healing behavior.

## Deployment Restart Recovery Test

A deployment restart was performed:

```powershell
kubectl rollout restart deployment/sre-ecs-web -n sre-lab
```

The rollout completed successfully.

Result:

```text
Deployment restarted successfully
Rollout completed
Deployment returned to READY 2/2
Pods remained healthy
```

## Rollback Script Test

The rollback script was tested in history-only mode:

```powershell
.\scripts\phase5\rollback-eks-app.ps1 -ShowHistory
```

Then an actual rollback was tested:

```powershell
.\scripts\phase5\rollback-eks-app.ps1
```

Result:

```text
Rollback command executed
Deployment successfully rolled out
Deployment returned to READY 2/2
Rollback completed successfully
```

## Bad Release Rollback Test

A bad release was simulated by updating the deployment to use a non-existent image tag.

The rollout failed as expected:

```text
Rollout timed out
New pod entered ImagePullBackOff
Existing healthy pods stayed Running
Deployment stayed AVAILABLE 2/2
```

The rollback script was then used to recover the application.

Result:

```text
Bad release was rolled back
ImagePullBackOff pod was removed
Deployment returned to READY 2/2
Healthy pods remained Running
```

This confirmed that the release process could fail safely and recover using rollback automation.

## Final Phase 5 Results

Phase 5 successfully demonstrated:

```text
CI/CD validation
Safe deployment automation
Release safety checks
Application health verification
Recovery automation
Rollback automation
Pod failure recovery
Deployment restart recovery
Bad release rollback
```

## Phase 5 Status

```text
Phase 5A — Phase 5 branch: complete
Phase 5B — GitLab CI/CD validation pipeline: complete
Phase 5C — Deployment and recovery scripts: complete
Phase 5D — Local validation testing: complete
Phase 5E — Release safety checks: complete
Phase 5F — Rollback script: complete
Phase 5G — Live failure testing: complete
Phase 5H — Phase 5 documentation: complete
```

## Notes

The GitLab CI/CD pipeline is validation-only. It does not currently run Terraform apply or deploy to AWS.

This is intentional for safety. A future improvement could add controlled deployment through GitLab CI/CD using AWS OIDC, Terraform plan review, and manual approval before apply.

Dashboards and SLOs were not completed in Phase 4 and are planned as follow-up observability improvements after Phase 5.
