# Phase 1B User Data Failure

## Summary

After adding CloudWatch visibility to the EC2 web server, Terraform successfully applied the infrastructure changes, but the website was unreachable over HTTP.

## Symptoms

- `Invoke-WebRequest` failed with "Unable to connect to the remote server."
- `Test-NetConnection` to port 80 returned `TcpTestSucceeded : False`.
- EC2 console output showed `cloud-init` failed to run `scripts-user`.

## Investigation

The EC2 instance existed and Terraform state showed the resources were created. The issue was not the Terraform apply itself. The failure occurred during EC2 bootstrapping through the `user_data` script.

## Root Cause

The `user_data` script had formatting issues, including heredoc indentation and invalid CloudWatch Agent JSON formatting. Because the startup script failed, Nginx did not become reachable on port 80.

## Resolution

Corrected the `user_data` script by:

- Left-aligning heredoc markers such as `HTML`, `CWCONFIG`, and `EOF`.
- Ensuring `#!/bin/bash` started at the beginning of the line.
- Fixing CloudWatch Agent JSON formatting.
- Making the script log to `/var/log/user-data.log`.
- Allowing Nginx to continue running even if CloudWatch Agent setup fails.

## Validation

After applying the fixed Terraform plan, the web server returned HTTP 200 OK.

## SRE Lesson

Infrastructure creation and service readiness are not the same thing. Terraform can successfully create an EC2 instance while the application still fails during bootstrapping. Reliable systems need validation, logs, and troubleshooting paths beyond successful provisioning.