#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 <cluster-name> <service-name> [region]" >&2
  exit 1
fi

cluster_name="$1"
service_name="$2"
region="${3:-us-east-1}"

task_arn=$(aws ecs list-tasks --cluster "$cluster_name" --service-name "$service_name" --region "$region" --query 'taskArns[0]' --output text)
if [[ -z "$task_arn" || "$task_arn" == "None" ]]; then
  echo "No running tasks found for service '$service_name' in cluster '$cluster_name'" >&2
  exit 1
fi

eni_id=$(aws ecs describe-tasks --tasks "$task_arn" --cluster "$cluster_name" --region "$region" --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)
if [[ -z "$eni_id" || "$eni_id" == "None" ]]; then
  echo "No ENI found for task $task_arn (task may still be starting)" >&2
  exit 1
fi

public_ip=$(aws ec2 describe-network-interfaces --network-interface-ids "$eni_id" --region "$region" --query 'NetworkInterfaces[0].Association.PublicIp' --output text)
if [[ -z "$public_ip" || "$public_ip" == "None" ]]; then
  echo "No public IP associated with ENI $eni_id (wait a minute and retry)" >&2
  exit 2
fi

echo "http://$public_ip/"
