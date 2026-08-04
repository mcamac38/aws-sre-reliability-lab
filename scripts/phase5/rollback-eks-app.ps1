[CmdletBinding()]
param(
	[string]$Namespace = "sre-lab",
	[string]$DeploymentName = "sre-ecs-web",
	[switch]$ShowHistory
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Assert-CommandExists {
	param([string]$CommandName)
	
	if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
		throw "Required command '$CommandName' was not found. Install it or add it to PATH."
	}
}

Write-Host "Starting EKS application rollback..." -ForegroundColor Cyan

Assert-CommandExists -CommandName "kubectl"

Write-Host "`nCurrent kubectl context:" -Foreground Yellow
kubectl config current-context

Write-Host "`nCurrent deployment status:" -ForegroundColor Yellow
kubectl get deployment $DeploymentName -n $Namespace

Write-Host "`nCurrent pods:" -ForegroundColor Yellow
kubectl get pods -n $Namespace -o wide

Write-Host "`nRollout history:" -ForegroundColor Yellow
kubectl rollout history "deployment/$DeploymentName" -n $Namespace

if ($ShowHistory) {
	Write-Host "`nRollback history shown only. No rollback performed." -ForegroundColor Cyan
	exit 0
}

Write-Host "`nRolling back deployment to previous revision..." -ForegroundColor Yellow
kubectl rollout undo "deployment/$DeploymentName" -n $Namespace

Write-Host "`nWaiting for rollback rollout to complete..." -ForegroundColor Yellow
kubectl rollout status "deployment/$DeploymentName" -n $Namespace --timeout=180s

Write-Host "`nFinal deployment status:" -ForegroundColor Green
kubectl get deployment $DeploymentName -n $Namespace

Write-Host "`nFinal pods:" -ForegroundColor Green
kubectl get pods -n $Namespace -o wide

Write-Host "`nFinal rollout history" -ForegroundColor Green
kubectl rollout history "deployment/$DeploymentName" -n $Namespace

Write-Host "`nRollback completed successfully." -ForegroundColor Cyan