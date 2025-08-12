param(
  [Parameter(Mandatory=$true)][string]$ClusterName,
  [Parameter(Mandatory=$true)][string]$ServiceName,
  [string]$Region = "us-east-1"
)

$taskArn = aws ecs list-tasks --cluster $ClusterName --service-name $ServiceName --region $Region --query 'taskArns[0]' --output text
if ([string]::IsNullOrWhiteSpace($taskArn) -or $taskArn -eq 'None') {
  Write-Error "No running tasks found for service '$ServiceName' in cluster '$ClusterName'"
  exit 1
}

$eniId = aws ecs describe-tasks --tasks $taskArn --cluster $ClusterName --region $Region --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text
if ([string]::IsNullOrWhiteSpace($eniId) -or $eniId -eq 'None') {
  Write-Error "No ENI found for task $taskArn (task may still be starting)"
  exit 1
}

$publicIp = aws ec2 describe-network-interfaces --network-interface-ids $eniId --region $Region --query 'NetworkInterfaces[0].Association.PublicIp' --output text
if ([string]::IsNullOrWhiteSpace($publicIp) -or $publicIp -eq 'None') {
  Write-Error "No public IP associated with ENI $eniId (wait a minute and retry)"
  exit 2
}

Write-Output "http://$publicIp/"