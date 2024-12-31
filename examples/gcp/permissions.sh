#!/bin/bash

# Retrieve the active project
PROJECT_ID=$(gcloud config get-value project)

ALL_PERMISSIONS=(
  "compute.instanceGroupManagers.update"
  "compute.instanceGroupManagers.delete"
  "compute.instanceGroupManagers.get"
  "compute.instanceGroupManagers.list"
  "compute.instances.list"
  "compute.instanceGroupManagers.update"
  "deploymentmanager.deployments.create"
  "deploymentmanager.deployments.delete"
  "deploymentmanager.deployments.get"
  "deploymentmanager.resources.get"
  "deploymentmanager.deployments.list"
  "deploymentmanager.deployments.get"
  "deploymentmanager.deployments.update"
  "deploymentmanager.deployments.update"
  "deploymentmanager.deployments.update"
  "compute.subnetworks.create"
  "compute.networks.update"
  "compute.firewalls.create"
  "compute.firewalls.create"
  "compute.networks.create"
  "compute.instanceTemplates.create"
  "compute.routes.create"
  "compute.firewalls.create"
  "compute.subnetworks.create"
  "compute.instances.setLabels"
  "compute.networks.create"
  "compute.networks.delete"
  "compute.instanceTemplates.delete"
  "compute.routes.delete"
  "compute.firewalls.delete"
  "compute.subnetworks.delete"
  "compute.networks.delete"
  "compute.projects.get"
  "compute.images.list"
  "compute.machineTypes.list"
  "compute.networks.list"
  "compute.instances.get"
  "compute.instanceTemplates.get"
  "compute.instanceTemplates.list"
  "compute.networks.get"
  "compute.instances.get"
  "compute.routes.list"
  "compute.firewalls.list"
  "compute.subnetworks.list"
  "compute.networks.get"
  "compute.networks.list"
  "compute.networks.update"
  "compute.routes.delete"
  "compute.subnetworks.update"
  "compute.networks.update"
  "compute.projects.setCommonInstanceMetadata"
  "compute.firewalls.delete"
  "compute.firewalls.delete"
  "compute.instances.create"
  "container.clusters.update"
  "container.clusters.create"
  "iam.serviceAccounts.create"
  "container.clusters.update"
  "container.clusters.delete"
  "iam.serviceAccounts.delete"
  "container.clusters.get"
  "container.clusters.list"
  "container.clusters.getIamPolicy"
  "container.operations.list"
  "container.clusters.update"
  "iam.serviceAccounts.setIamPolicy"
  "iam.roles.update"
  "iam.serviceAccounts.create"
  "iam.workloadIdentityPools.create"
  "iam.roles.create"
  "iam.serviceAccounts.create"
  "iam.serviceAccounts.delete"
  "iam.workloadIdentityPools.delete"
  "iam.roles.delete"
  "iam.roles.update"
  "iam.serviceAccounts.get"
  "iam.roles.get"
  "iam.roles.list"
  "iam.serviceAccounts.actAs"
  "cloudkms.cryptoKeys.create"
  "cloudkms.keyRings.create"
  "cloudkms.cryptoKeys.getIamPolicy"
  "cloudkms.cryptoKeys.list"
  "logging.sinks.create"
  "logging.logs.delete"
  "logging.logs.list"
  "pubsub.topics.create"
  "pubsub.topics.delete"
  "pubsub.topics.get"
  "pubsub.topics.update"
)


# Ensure PROJECT_ID is set
if [ -z "$PROJECT_ID" ]; then
  echo "Project ID is not set. Please set the project using 'gcloud config set project PROJECT_ID'"
  exit 1
fi

# Get the authenticated user
USER_EMAIL=$(gcloud config get-value account)
roles=$(gcloud projects get-iam-policy $PROJECT_ID --flatten="bindings[].members" \
            --filter="bindings.members:$USER_EMAIL" \
            --format="json(bindings.role)" | jq -r '.[].bindings.role')

# Print roles
echo "Roles assigned to $USER_EMAIL:"
echo "$roles"

echo -e "\nFetching permissions for each role..."

# Initialize user_permissions variable
user_permissions=""

# Loop through each role and fetch permissions
for role in $roles; do
  echo -e "\nRole: $role"
  
  # Check if it's a custom or predefined role
  if [[ "$role" == roles/* ]]; then
    permissions=$(gcloud iam roles describe "$role" --format="json" | jq -r '.includedPermissions[]' 2>/dev/null)
  else
    permissions=$(gcloud iam roles describe "${role##*/}" --format="json" | jq -r '.includedPermissions[]' 2>/dev/null)
  fi
  
  # Append permissions to the user_permissions variable
  user_permissions+="$permissions"$'\n'
done

REMAINING_PERMISSIONS=()

# Loop through all permissions and check if they're assigned
for PERMISSION in "${ALL_PERMISSIONS[@]}"; do
  if ! echo "$user_permissions" | grep -q "$PERMISSION"; then
    REMAINING_PERMISSIONS+=("$PERMISSION")
  fi
done

# Print remaining permissions (if any)
if [ ${#REMAINING_PERMISSIONS[@]} -eq 0 ]; then
  echo "All required permissions are assigned."
else
  echo "Missing permissions:"
  printf '%s\n' "${REMAINING_PERMISSIONS[@]}"

  # Ask user for approval to create the role
  echo -n "Custom role is successfully created. Do you want to attach this role to your GCP user? (y/N): "
  read APPROVAL

  if [[ "$APPROVAL" =~ ^[Yy]$ ]]; then
    ROLE_NAME="custom_dsh_role_$(date +%s | head -c 10)"
    ROLE_FILE="custom_dsh_role.json"
    echo "Creating the custom role..."

    # Create custom role JSON file
    cat > "$ROLE_FILE" <<EOF
{
  "title": "Custom Role for Missing Permissions",
  "description": "Custom role to provide missing permissions for user.",
  "includedPermissions": $(printf '%s\n' "${REMAINING_PERMISSIONS[@]}" | jq -R . | jq -s .),
  "stage": "GA"
}
EOF

    # Create the role using gcloud
    gcloud iam roles create "$ROLE_NAME" --project="$PROJECT_ID" --file="$ROLE_FILE"

    # Correct role name format for attachment
    ROLE_RESOURCE="projects/$PROJECT_ID/roles/$ROLE_NAME"

    # Attach the custom role to the user
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
      --member="user:$USER_EMAIL" \
      --role="$ROLE_RESOURCE"

    echo "Role created and assigned to $USER_EMAIL."
  else
    echo "User did not approve. No changes made."
  fi
fi