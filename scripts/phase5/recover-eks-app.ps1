[CmdletBinding()]
param(
	[string]$Namespace = "sre-lab",
	[string]$DeploymentName = "sre-ecs-web",
	[string]$ManifestPath = "kubernetes\phase3-eks\flask-app.yaml",
	[switch]$ReapplyManifest
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "Starting EKS application recovery..." -ForegroundColor Cyan

Write-Host "`nCurrent deployment state:" -ForegroundColor Yellow
kubectl get deployment $DeploymentName -n $Namespace

Write-Host "`nCurrent pods:" -ForegroundColor Yellow
kubectl get pods -n $Namespace -o wide

if ($ReapplyManifest) {
	if(-not (Test-Path $ManifestPath)) {
		throw "Manifest not found: $ManifestPath"
	}
    
	Write-Host "`nReapplying manifest: $ManifestPath" -ForegroundColor Yellow
	kubectl apply -f $ManifestPath
}

Write-Host "`nRestarting deployment..." -ForegroundColor Yellow
kubectl rollout restart "deployment/$DeploymentName" -n $Namespace

Write-Host "`nWaiting for rollout to complete..." -ForegroundColor Yellow
kubectl rollout status "deployment/$DeploymentName" -n $Namespace --timeout=180s

Write-Host "`nFinal deployment state:" -ForegroundColor Green
kubectl get deployment $DeploymentName -n $Namespace

Write-Host "`nFinal pods:" -ForegroundColor Green
kubectl get pods -n $Namespace -o wide

Write-Host "`nRecovery completed successfully." -ForegroundColor Cyan
