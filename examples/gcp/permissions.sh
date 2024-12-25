#!/bin/bash

# Retrieve the active project
PROJECT_ID=$(gcloud config get-value project)

ALL_PERMISSIONS=(
  "compute.instances.setLabels"
  "compute.instanceGroupManagers.delete"
  "compute.instanceGroupManagers.get"
  "compute.instanceGroupManagers.update"
  "deploymentmanager.deployments.create"
  "deploymentmanager.deployments.delete"
  "deploymentmanager.operations.get"
  "deploymentmanager.resources.get"
  "deploymentmanager.deployments.get"
  "deploymentmanager.manifests.get"
  "deploymentmanager.deployments.update"
  "deploymentmanager.types.list"
  "compute.routes.create"
  "compute.subnetworks.update"
  "compute.networks.updatePolicy"
  "compute.firewalls.create"
  "compute.instanceTemplates.create"
  "compute.routers.create"
  "compute.subnetworks.create"
  "compute.networks.create"
  "compute.networks.delete"
  "compute.instanceTemplates.delete"
  "compute.routers.delete"
  "compute.firewalls.delete"
  "compute.subnetworks.delete"
  "resourcemanager.projects.get"
  "compute.images.list"
  "compute.machineTypes.list"
  "compute.networks.list"
  "compute.instances.get"
  "compute.instanceTemplates.get"
  "compute.networks.get"
  "compute.routes.list"
  "compute.firewalls.list"
  "compute.subnetworks.list"
  "compute.routes.delete"
  "compute.instances.create"
  "container.clusters.create"
  "container.nodePools.create"
  "container.clusters.delete"
  "container.nodePools.delete"
  "container.clusters.get"
  "container.nodePools.get"
  "container.clusters.update"
  "container.nodePools.update"
  "compute.instances.attachDisk"
  "compute.instances.setMetadata"
  "pubsub.topics.delete"
  "pubsub.topics.get"
  "pubsub.topics.getIamPolicy"
  "pubsub.topics.create"
  "pubsub.topics.update"
  "pubsub.subscriptions.create"
  "pubsub.subscriptions.delete"
  "iam.serviceAccounts.create"
  "iam.roles.create"
  "iam.serviceAccounts.delete"
  "iam.roles.delete"
  "iam.serviceAccounts.actAs"
  "cloudkms.cryptoKeys.create"
  "cloudkms.cryptoKeys.get"
  "cloudkms.cryptoKeys.getIamPolicy"
  "cloudkms.keyRings.get"
  "cloudkms.cryptoKeys.setIamPolicy"
)


# Ensure PROJECT_ID is set
if [ -z "$PROJECT_ID" ]; then
  echo "Project ID is not set. Please set the project using 'gcloud config set project PROJECT_ID'"
  exit 1
fi

# Get the authenticated user
USER_EMAIL=$(gcloud config get-value account)

# Extract roles assigned to the user
echo "Extracting roles for $USER_EMAIL..."
roles=$(jq -r '.[] | .bindings[] | select(.members[] | contains("'$USER_EMAIL'")) | .role' roles_assigned.json | sort -u)

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
    REMAINING_PERMISSIONS+=("\"$PERMISSION\"")
  fi
done

# Print remaining permissions (if any)
if [ ${#REMAINING_PERMISSIONS[@]} -eq 0 ]; then
  echo "All required permissions are assigned."
else
  echo "Missing permissions:"
  printf '%s\n' "${REMAINING_PERMISSIONS[@]}"

  # Ask user for approval to create the role
  echo -n "Do you approve creating a custom role with these permissions and attaching it to you? (y/N): "
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