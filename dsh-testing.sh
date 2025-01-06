name: Deploy DevZero Control Plane

on:
  push:
    branches:
      - main

jobs:
  apply:
    name: Apply Terraform
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
      - name: Set up AWS CLI
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: "us-west-1"
      - name: Install Helm
        run: |
          curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
      - name: Run Apply Stage
        run: |
          chmod +x ./dsh-testing.sh
          DOMAIN_NAME="${{ secrets.DOMAIN_NAME }}"
          EMAIL="${{ secrets.EMAIL }}"
          TF_BACKEND="S3"
          BUCKET_NAME="${{ secrets.BUCKET_NAME }}"
          ./dsh-testing.sh apply_terraform

  # eks-setup:
  #   name: EKS Setup
  #   runs-on: ubuntu-latest
  #   needs: apply
  #   steps:
  #     - name: Checkout code
  #       uses: actions/checkout@v4
  #     - name: Set up AWS CLI
  #       uses: aws-actions/configure-aws-credentials@v4
  #       with:
  #         aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
  #         aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  #         aws-region: "us-west-1"
  #     - name: Run EKS Setup Stage
  #       run: |
  #         chmod +x ./dsh-testing.sh
  #         ./dsh-testing.sh get_eks_info
  #         ./dsh-testing.sh configure_kubeconfig
  #         ./dsh-testing.sh login_to_helm_registry
  #         ./dsh-testing.sh install_devzero_crds
  #         ./dsh-testing.sh install_devzero_control_plane
  #         ./dsh-testing.sh get_ingress_service

  destroy:
    name: Terraform Destroy
    runs-on: ubuntu-latest
    needs: eks-setup
    if: always()
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
      - name: Set up AWS CLI
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: "us-west-1"
      - name: Run Destroy Stage
        run: |
          chmod +x ./dsh-testing.sh
          ./dsh-testing.sh cleanup
}

main

