[CmdletBinding()]
param(
	[string]$ClusterName = "sre-lab-phase3-eks-cluster",
	[string]$AwsProfile = "terraform_learn",
	[string]$Region = "us-east-2",
	[string]$Namespace = "sre-lab",
	[string]$DeploymentName = "sre-ecs-web",
	[string]$AppManifestPath = "kubernetes\phase3-eks\flask-app.yaml",
	[string]$HpaManifestPath = "kubernetes\phase4-observability\hpa.yaml",
	[switch]$SkipDryRun
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Assert-CommandExists {
	param([string]$CommandName)
	
	if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
		throw "Required command '$CommandName' was not found. Install it or add it to PATH."
    }
}


function Assert-FileExists {
	param([string]$Path)
	
	if (-not (Test-Path $Path)) {
		throw "Required file was not found: $Path"
	}
}

	
Write-Host "Starting EKS app deployment..." -ForegroundColor Cyan

Assert-CommandExists -CommandName "aws"
Assert-CommandExists -CommandName "kubectl"

Assert-FileExists -Path $AppManifestPath

Write-Host "Updating kubeconfig for cluster: $ClusterName" -ForegroundColor Yellow
aws eks update-kubeconfig `
	--name $ClusterName `
	--profile $AwsProfile `
	--region $Region
	
$currentContext = kubectl config current-context

Write-Host "Current kubectl context: $currentContext" -ForegroundColor Yellow

if ($currentContext -notmatch [regex]::Escape($ClusterName)) {
	throw "Release safety check failed. Current kubectl context does not match expected cluster '$ClusterName'."
}
	
if (-not $SkipDryRun) {
	Write-Host "Running client-side dry run for application manifest..." -ForegroundColor Yellow
	kubectl apply --dry-run=client -f $AppManifestPath
	
	if (Test-Path $HpaManifestPath) {
		Write-Host "Running client-side dry run for HPA manifest..." -ForegroundColor Yellow
		kubectl apply --dry-run=client -f $HpaManifestPath
	}
	else {
		Write-Host "HPA manifest not found, skipping dry run: $HpaManifestPath" -ForegroundColor DarkYellow
	}
}

Write-Host "Applying application manifest..." -ForegroundColor Yellow
kubectl apply -f $AppManifestPath

if (Test-Path $HpaManifestPath) {
	Write-Host "Applying HPA manifest..." -ForegroundColor Yellow
	kubectl apply -f $HpaManifestPath
}
else {
	Write-Host "HPA manifest not found, skipping apply: $HpaManifestPath" -ForegroundColor DarkYellow
}

Write-Host "Waiting for deployment rollout..." -ForegroundColor Yellow
kubectl rollout status "deployment/$DeploymentName" -n $Namespace --timeout=180s

Write-Host "Deployment status:" -ForegroundColor Green
kubectl get deployment $DeploymentName -n $Namespace

Write-Host "Pods:" -ForegroundColor Green
kubectl get pods -n $Namespace -o wide

Write-Host "Services:" -ForegroundColor Green
kubectl get service -n $Namespace

Write-Host "HPA:" -ForegroundColor Green
kubectl get hpa -n $Namespace

Write-Host "Safe EKS app deployment complete successfully." -ForegroundColor Cyan