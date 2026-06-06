\# Architecture Notes



\## Phase 0 Architecture



Local machine connects to AWS using:



PowerShell -> AWS CLI SSO Profile -> Terraform AWS Provider -> AWS Account



The current Terraform configuration only verifies AWS identity using the `aws\_caller\_identity` data source. It does not create AWS infrastructure.



\## Planned Architecture



The project will eventually include:



\- A containerized web API

\- EC2 deployment behind an Application Load Balancer.

\- ECS deployment using containers from Amazon ECR.

\- EKS deployment using Kubernetes manifests.

\- CloudWatch logs, metrics, alarms, and dashboards.

\- Failure testing and recovery documentation.



\## AWS Region



Primary working region:



`us-east-2`



\## Terraform Profile



Local AWS CLI profile:



`terraform\_learn`

