[CmdletBinding()]
param(
	[string]$ClusterName = "sre-lab-phase3-eks-cluster",
	[string]$AwsProfile = "terraform_learn",
	[string]$Region = "us-east-2",
	[string]$Namespace = "sre-lab",
	[string]$DeploymentName = "sre-ecs-web"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "Checking EKS cluster health..." -ForegroundColor Cyan

Write-Host "`nEKS cluster status:" -ForegroundColor Yellow
aws eks describe-cluster `
	--name $ClusterName `
	--profile $AwsProfile `
	--region $Region `
	--query "cluster.[name,status,version]" `
	--output table
	
Write-Host "`nEKS nodes:" -ForegroundColor Yellow
kubectl get nodes -o wide

Write-Host "`nSystem pods:" -ForegroundColor Yellow
kubectl get pods -n kube-system

Write-Host "`nApplication deployment:" -ForegroundColor Yellow
kubectl get deployment $DeploymentName -n $Namespace

Write-Host "`nApplication pods:" -ForegroundColor Yellow
kubectl get pods -n $Namespace -o wide

Write-Host "`nApplication Service:" -ForegroundColor Yellow
kubectl get service -n $Namespace

Write-Host "`nHPA:" -ForegroundColor Yellow
kubectl get hpa -n $Namespace

Write-Host "`nCloudWatch alarm states:" -ForegroundColor Yellow
aws cloudwatch describe-alarms `
	--profile $AwsProfile `
	--region $Region `
	--alarm-name-prefix "sre-lab-phase3-eks" `
	--query "MetricAlarms[*].[AlarmName,StateValue,MetricName,Namespace]" `
	--output table
	
Write-Host "`nHealth verification completed." -ForegroundColor Cyan