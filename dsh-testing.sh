#!/bin/bash

set -e   

apply_terraform() {
  echo "Initializing Terraform..."
  if [[ "$TF_BACKEND" == "S3" ]]; then
    terraform init -backend-config="bucket=dsh-testing-tf-state-2" \
                   -backend-config="key=devzero/terraform.tfstate" \
                   -backend-config="region=us-west-1"
  else
    terraform init
  fi
  echo "Applying Terraform configuration..."
  terraform apply -auto-approve
}

get_eks_info() {
  CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
  AWS_REGION=$(terraform output -raw region)
}

configure_kubeconfig() {
  aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
}

login_to_helm_registry() {
  docker login -u $DZ_USERNAME -p $DZ_PASSWORD
}

install_devzero_crds() {
  helm pull oci://registry-1.docker.io/devzeroinc/dz-data-plane-crds
  helm install dz-control-plane-crds oci://registry-1.docker.io/devzeroinc/dz-control-plane-crds -n devzero --create-namespace
}

install_devzero_control_plane() {
  helm pull oci://registry-1.docker.io/devzeroinc/dz-control-plane
  helm install dz-control-plane oci://registry-1.docker.io/devzeroinc/dz-control-plane -n devzero --set domain=dsh-testing.com --set issuer.email=support@devzero.io --set credentials.registry=docker.io/devzeroinc --set credentials.username=$HELM_USER --set credentials.password=$HELM_PSWD --set credentials.email=support@devzero.io
}

get_ingress_service() {
  kubectl get ingress -n devzero
}

cleanup() {
  echo "Cleaning up resources..."
  terraform destroy -auto-approve
  echo "Resources cleaned up."
}
