$attempt = 1

Write-Host "Starting GitOps brute-force loop for OCI capacity..."

while ($true) {
    Write-Host "========================================"
    Write-Host "Attempt $attempt: Triggering HCP Terraform Pipeline"
    Write-Host "========================================"
    
    # Create an empty commit to trigger the webhook without modifying files
    git commit --allow-empty -m "chore: automated retry loop for OCI ARM capacity ($attempt)"
    
    # Push to GitHub to fire the webhook to HCP Terraform
    git push origin main
    
    # Wait 5 minutes before the next attempt to allow the Plan/Apply to finish or fail
    Write-Host "Waiting 300 seconds for HCP Terraform run to process..."
    Start-Sleep -Seconds 300
    
    $attempt++
}