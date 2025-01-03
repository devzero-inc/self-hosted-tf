#!/bin/bash

set -e  

DOMAIN_NAME="example.com"     
DZ_USERNAME="devzero@devzero.io"    
DZ_PASSWORD="2pbYZNk2ziRqmIuOrwsUS00gXew"   
EMAIL="support@devzero.io" \

cleanup() {
  echo "Cleaning up resources..."
  terraform destroy -auto-approve
  echo "Resources cleaned up."
}
trap cleanup EXIT

cd examples/aws/control-and-data-plane

terraform init

terraform apply -auto-approve

CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
AWS_REGION=$(terraform output -raw region)

aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

# helm registry login registry.devzero.io --username $DZ_USERNAME --password $DZ_PASSWORD

# helm install dz-control-plane-crds oci://registry.devzero.io/devzero-control-plane/beta/dz-control-plane-crds \
#   -n devzero --create-namespace

# helm install dz-control-plane oci://registry.devzero.io/devzero-control-plane/beta/dz-control-plane \
#   -n devzero --set domain=$DOMAIN_NAME --set issuer.email=$EMAIL

# kubectl get ingress -n devzero

echo "DevZero control plane setup completed successfully!"
