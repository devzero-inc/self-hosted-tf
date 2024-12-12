#!/bin/bash

control_plane_actions=(
    "autoscaling:CreateOrUpdateTags"
    "autoscaling:DeleteLifecycleHook"
    "autoscaling:DeleteTags"
    "autoscaling:DescribeLifecycleHookTypes"
    "autoscaling:DescribeLifecycleHooks"
    "autoscaling:DescribeTags"
    "autoscaling:PutLifecycleHook"
    "cloudformation:CreateStack"
    "cloudformation:DeleteStack"
    "cloudformation:DescribeStackEvents"
    "cloudformation:DescribeStackResources"
    "cloudformation:DescribeStacks"
    "cloudformation:GetTemplate"
    "cloudformation:SetStackPolicy"
    "cloudformation:UpdateStack"
    "cloudformation:UpdateTerminationProtection"
    "cloudformation:ValidateTemplate"
    "ec2:AssociateRouteTable"
    "ec2:AssociateSubnetCidrBlock"
    "ec2:AttachInternetGateway"
    "ec2:AuthorizeSecurityGroupEgress"
    "ec2:AuthorizeSecurityGroupIngress"
    "ec2:CreateInternetGateway"
    "ec2:CreateLaunchTemplate"
    "ec2:CreateLaunchTemplateVersion"
    "ec2:CreateRouteTable"
    "ec2:CreateSecurityGroup"
    "ec2:CreateSubnet"
    "ec2:CreateTags"
    "ec2:CreateVPC"
    "ec2:DeleteInternetGateway"
    "ec2:DeleteLaunchTemplate"
    "ec2:DeleteRouteTable"
    "ec2:DeleteSecurityGroup"
    "ec2:DeleteSubnet"
    "ec2:DeleteTags"
    "ec2:DeleteVPC"
    "ec2:DescribeAccountAttributes"
    "ec2:DescribeImages"
    "ec2:DescribeInstanceTypes"
    "ec2:DescribeInternetGateways"
    "ec2:DescribeKeyPairs"
    "ec2:DescribeLaunchTemplateVersions"
    "ec2:DescribeLaunchTemplates"
    "ec2:DescribeNetworkAcls"
    "ec2:DescribeNetworkInterfaces"
    "ec2:DescribeRouteTables"
    "ec2:DescribeSecurityGroups"
    "ec2:DescribeSubnets"
    "ec2:DescribeVpcAttribute"
    "ec2:DescribeVpcs"
    "ec2:DetachInternetGateway"
    "ec2:DisassociateRouteTable"
    "ec2:DisassociateSubnetCidrBlock"
    "ec2:ModifySubnetAttribute"
    "ec2:ModifyVpcAttribute"
    "ec2:ModifyVpcTenancy"
    "ec2:ReplaceRouteTableAssociation"
    "ec2:RevokeSecurityGroupEgress"
    "ec2:RevokeSecurityGroupIngress"
    "ec2:RunInstances"
    "eks:CreateAddon"
    "eks:CreateCluster"
    "eks:CreateNodegroup"
    "eks:CreatePodIdentityAssociation"
    "eks:DeleteAddon"
    "eks:DeleteCluster"
    "eks:DeleteNodegroup"
    "eks:DeletePodIdentityAssociation"
    "eks:DescribeAddon"
    "eks:DescribeAddonVersions"
    "eks:DescribeCluster"
    "eks:DescribeNodegroup"
    "eks:ListAddons"
    "eks:ListTagsForResource"
    "eks:ListUpdates"
    "eks:TagResource"
    "eks:UntagResource"
    "eks:UpdateAddon"
    "eks:UpdateClusterConfig"
    "eks:UpdateNodegroupConfig"
    "eks:UpdateNodegroupVersion"
    "elasticfilesystem:CreateFileSystem"
    "elasticfilesystem:CreateMountTarget"
    "elasticfilesystem:DeleteFileSystem"
    "elasticfilesystem:DeleteMountTarget"
    "elasticfilesystem:DescribeFileSystems"
    "elasticfilesystem:DescribeLifecycleConfiguration"
    "elasticfilesystem:DescribeMountTargetSecurityGroups"
    "elasticfilesystem:DescribeMountTargets"
    "elasticfilesystem:ModifyMountTargetSecurityGroups"
    "events:DeleteRule"
    "events:DescribeRule"
    "events:ListTagsForResource"
    "events:ListTargetsByRule"
    "events:PutRule"
    "events:PutTargets"
    "events:RemoveTargets"
    "events:TagResource"
    "events:UnTagResource"
    "iam:AddRoleToInstanceProfile"
    "iam:AttachRolePolicy"
    "iam:CreateInstanceProfile"
    "iam:CreateOpenIDConnectProvider"
    "iam:CreatePolicy"
    "iam:CreateRole"
    "iam:CreateServiceLinkedRole"
    "iam:DeleteInstanceProfile"
    "iam:DeleteOpenIDConnectProvider"
    "iam:DeletePolicy"
    "iam:DeleteRole"
    "iam:DeleteRolePermissionsBoundary"
    "iam:DetachRolePolicy"
    "iam:GetInstanceProfile"
    "iam:GetOpenIDConnectProvider"
    "iam:GetPolicy"
    "iam:GetPolicyVersion"
    "iam:GetRole"
    "iam:ListAttachedRolePolicies"
    "iam:ListInstanceProfilesForRole"
    "iam:ListPolicyVersions"
    "iam:ListRolePolicies"
    "iam:PassRole"
    "iam:PutRolePermissionsBoundary"
    "iam:RemoveRoleFromInstanceProfile"
    "iam:TagInstanceProfile"
    "iam:TagOpenIDConnectProvider"
    "iam:TagPolicy"
    "iam:TagRole"
    "iam:UntagInstanceProfile"
    "iam:UntagOpenIDConnectProvider"
    "iam:UntagPolicy"
    "iam:UntagRole"
    "iam:UpdateOpenIDConnectProviderThumbprint"
    "iam:UpdateRoleDescription"
    "kms:CreateAlias"
    "kms:CreateKey"
    "kms:DeleteAlias"
    "kms:DescribeKey"
    "kms:GetKeyPolicy"
    "kms:GetKeyRotationStatus"
    "kms:ListAliases"
    "kms:ListResourceTags"
    "kms:PutKeyPolicy"
    "kms:ScheduleKeyDeletion"
    "kms:UpdateAlias"
    "logs:AssociateKmsKey"
    "logs:CreateLogGroup"
    "logs:DeleteLogGroup"
    "logs:DeleteRetentionPolicy"
    "logs:DescribeLogGroups"
    "logs:DisassociateKmsKey"
    "logs:ListTagsLogGroup"
    "logs:PutRetentionPolicy"
    "logs:TagLogGroup"
    "logs:UntagLogGroup"
    "sqs:CreateQueue"
    "sqs:DeleteQueue"
    "sqs:GetQueueAttributes"
    "sqs:GetQueueUrl"
    "sqs:ListQueueTags"
    "sqs:SetQueueAttributes"
    "sqs:TagQueue"
    "sqs:UntagQueue"
)

data_plane_actions=(
    "autoscaling:CreateOrUpdateTags"
    "autoscaling:DeleteLifecycleHook"
    "autoscaling:DeleteTags"
    "autoscaling:DescribeLifecycleHookTypes"
    "autoscaling:DescribeLifecycleHooks"
    "autoscaling:DescribeTags"
    "autoscaling:PutLifecycleHook"
    "cloudformation:CreateStack"
    "cloudformation:DeleteStack"
    "cloudformation:DescribeStackEvents"
    "cloudformation:DescribeStackResources"
    "cloudformation:DescribeStacks"
    "cloudformation:GetTemplate"
    "cloudformation:SetStackPolicy"
    "cloudformation:UpdateStack"
    "cloudformation:UpdateTerminationProtection"
    "cloudformation:ValidateTemplate"
    "ec2:AssociateRouteTable"
    "ec2:AssociateSubnetCidrBlock"
    "ec2:AttachInternetGateway"
    "ec2:AuthorizeSecurityGroupEgress"
    "ec2:AuthorizeSecurityGroupIngress"
    "ec2:CreateInternetGateway"
    "ec2:CreateLaunchTemplate"
    "ec2:CreateLaunchTemplateVersion"
    "ec2:CreateRouteTable"
    "ec2:CreateSecurityGroup"
    "ec2:CreateSubnet"
    "ec2:CreateTags"
    "ec2:CreateVPC"
    "ec2:DeleteInternetGateway"
    "ec2:DeleteLaunchTemplate"
    "ec2:DeleteRouteTable"
    "ec2:DeleteSecurityGroup"
    "ec2:DeleteSubnet"
    "ec2:DeleteTags"
    "ec2:DeleteVPC"
    "ec2:DescribeAccountAttributes"
    "ec2:DescribeImages"
    "ec2:DescribeInstanceTypes"
    "ec2:DescribeInternetGateways"
    "ec2:DescribeKeyPairs"
    "ec2:DescribeLaunchTemplateVersions"
    "ec2:DescribeLaunchTemplates"
    "ec2:DescribeNetworkAcls"
    "ec2:DescribeNetworkInterfaces"
    "ec2:DescribeRouteTables"
    "ec2:DescribeSecurityGroups"
    "ec2:DescribeSubnets"
    "ec2:DescribeVpcAttribute"
    "ec2:DescribeVpcs"
    "ec2:DetachInternetGateway"
    "ec2:DisassociateRouteTable"
    "ec2:DisassociateSubnetCidrBlock"
    "ec2:ModifySubnetAttribute"
    "ec2:ModifyVpcAttribute"
    "ec2:ModifyVpcTenancy"
    "ec2:ReplaceRouteTableAssociation"
    "ec2:RevokeSecurityGroupEgress"
    "ec2:RevokeSecurityGroupIngress"
    "ec2:RunInstances"
    "eks:CreateAddon"
    "eks:CreateCluster"
    "eks:CreateNodegroup"
    "eks:CreatePodIdentityAssociation"
    "eks:DeleteAddon"
    "eks:DeleteCluster"
    "eks:DeleteNodegroup"
    "eks:DeletePodIdentityAssociation"
    "eks:DescribeAddon"
    "eks:DescribeAddonVersions"
    "eks:DescribeCluster"
    "eks:DescribeNodegroup"
    "eks:ListAddons"
    "eks:ListTagsForResource"
    "eks:ListUpdates"
    "eks:TagResource"
    "eks:UntagResource"
    "eks:UpdateAddon"
    "eks:UpdateClusterConfig"
    "eks:UpdateNodegroupConfig"
    "eks:UpdateNodegroupVersion"
    "elasticfilesystem:CreateFileSystem"
    "elasticfilesystem:CreateMountTarget"
    "elasticfilesystem:DeleteFileSystem"
    "elasticfilesystem:DeleteMountTarget"
    "elasticfilesystem:DescribeFileSystems"
    "elasticfilesystem:DescribeLifecycleConfiguration"
    "elasticfilesystem:DescribeMountTargetSecurityGroups"
    "elasticfilesystem:DescribeMountTargets"
    "elasticfilesystem:ModifyMountTargetSecurityGroups"
    "events:DeleteRule"
    "events:DescribeRule"
    "events:ListTagsForResource"
    "events:ListTargetsByRule"
    "events:PutRule"
    "events:PutTargets"
    "events:RemoveTargets"
    "events:TagResource"
    "events:UnTagResource"
    "iam:AddRoleToInstanceProfile"
    "iam:AttachRolePolicy"
    "iam:CreateInstanceProfile"
    "iam:CreateOpenIDConnectProvider"
    "iam:CreatePolicy"
    "iam:CreateRole"
    "iam:CreateServiceLinkedRole"
    "iam:DeleteInstanceProfile"
    "iam:DeleteOpenIDConnectProvider"
    "iam:DeletePolicy"
    "iam:DeleteRole"
    "iam:DeleteRolePermissionsBoundary"
    "iam:DetachRolePolicy"
    "iam:GetInstanceProfile"
    "iam:GetOpenIDConnectProvider"
    "iam:GetPolicy"
    "iam:GetPolicyVersion"
    "iam:GetRole"
    "iam:ListAttachedRolePolicies"
    "iam:ListInstanceProfilesForRole"
    "iam:ListPolicyVersions"
    "iam:ListRolePolicies"
    "iam:PassRole"
    "iam:PutRolePermissionsBoundary"
    "iam:RemoveRoleFromInstanceProfile"
    "iam:TagInstanceProfile"
    "iam:TagOpenIDConnectProvider"
    "iam:TagPolicy"
    "iam:TagRole"
    "iam:UntagInstanceProfile"
    "iam:UntagOpenIDConnectProvider"
    "iam:UntagPolicy"
    "iam:UntagRole"
    "iam:UpdateOpenIDConnectProviderThumbprint"
    "iam:UpdateRoleDescription"
    "kms:CreateAlias"
    "kms:CreateKey"
    "kms:DeleteAlias"
    "kms:DescribeKey"
    "kms:GetKeyPolicy"
    "kms:GetKeyRotationStatus"
    "kms:ListAliases"
    "kms:ListResourceTags"
    "kms:PutKeyPolicy"
    "kms:ScheduleKeyDeletion"
    "kms:UpdateAlias"
    "logs:AssociateKmsKey"
    "logs:CreateLogGroup"
    "logs:DeleteLogGroup"
    "logs:DeleteRetentionPolicy"
    "logs:DescribeLogGroups"
    "logs:DisassociateKmsKey"
    "logs:ListTagsLogGroup"
    "logs:PutRetentionPolicy"
    "logs:TagLogGroup"
    "logs:UntagLogGroup"
    "sqs:CreateQueue"
    "sqs:DeleteQueue"
    "sqs:GetQueueAttributes"
    "sqs:GetQueueUrl"
    "sqs:ListQueueTags"
    "sqs:SetQueueAttributes"
    "sqs:TagQueue"
    "sqs:UntagQueue"
)

required_actions=("${control_plane_actions[@]}")

prompt_deployment_type() {
    echo ""
    echo "Please select the deployment type:"
    echo "1. Control Plane"
    echo "2. Data Plane"
    read -p "Enter your choice (1 or 2): " choice
    echo ""
    case $choice in
        1)
            echo "You selected Control Plane."
            required_actions=("${control_plane_actions[@]}")
            ;;
        2)
            echo "You selected Data Plane."
            required_actions=("${data_plane_actions[@]}")
            ;;
        *)
            echo "Invalid choice. Defaulting to Control Plane."
            required_actions=("${control_plane_actions[@]}")
            ;;
    esac
}

check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI not found. Please install it first."
        exit 1
    fi
}

get_caller_identity() {
    aws sts get-caller-identity --query "Arn"
}

extract_role_name() {
    local arn=$1
    echo "$arn" | awk -F'/' '{print $(NF-1)}'
}

get_attached_policies() {
    local role_name=$1
    aws iam list-attached-role-policies --role-name "$role_name" --query "AttachedPolicies[].PolicyArn" --output text
}

get_inline_policies() {
    local role_name=$1
    aws iam list-role-policies --role-name "$role_name" --query "PolicyNames[]" --output text
}

get_policy_actions() {
    local policy_arn=$1
    aws iam get-policy-version --policy-arn "$policy_arn" --version-id $(aws iam list-policy-versions --policy-arn "$policy_arn" --query "Versions[0].VersionId" --output text) --query "PolicyVersion.Document.Statement[].Action" --output text
}

get_inline_policy_actions() {
    local role_name=$1
    local policy_name=$2
    aws iam get-role-policy --role-name "$role_name" --policy-name "$policy_name" --query "PolicyDocument.Statement[].Action" --output text
}

create_policy_json() {
    local output_file="policy.json"
    local missing_permissions=("$@")
    declare -A service_action_map

    for action in "${missing_permissions[@]}"; do
        service_prefix=$(echo "$action" | cut -d':' -f1)
        if [[ -z "${service_action_map[$service_prefix]}" ]]; then
            service_action_map[$service_prefix]="$action"
        else
            service_action_map[$service_prefix]="${service_action_map[$service_prefix]},$action"
        fi
    done

    echo "{" > $output_file
    echo "  \"Version\": \"2012-10-17\"," >> $output_file
    echo "  \"Statement\": [" >> $output_file

    for service_prefix in "${!service_action_map[@]}"; do
        echo "    {" >> $output_file
        echo "      \"Effect\": \"Allow\"," >> $output_file
        echo "      \"Action\": [" >> $output_file
        IFS=',' read -ra actions <<< "${service_action_map[$service_prefix]}"
        for action in "${actions[@]}"; do
            echo "        \"$action\"," >> $output_file
        done
        sed -i '$ s/,$//' $output_file  # Remove trailing comma
        echo "      ]," >> $output_file
        echo "      \"Resource\": \"*\"" >> $output_file
        echo "    }," >> $output_file
    done

  
    sed -i '$ s/,$//' $output_file

  
    echo "  ]" >> $output_file
    echo "}" >> $output_file

    echo "IAM policy saved to $output_file"
    echo "You will need to attach this policy to your AWS IAM role/user. More info: https://www.devzero.io/docs/admin/install/aws#adding-permissions-to-aws"
}


# Main script logic
check_aws_cli

# Get the caller identity ARN
if ! identity_arn=$(get_caller_identity 2>&1); then
    identity_arn=$(echo "$identity_arn" | sed '/./,$!d')
    echo "Failed to retrieve AWS caller identity:"
    echo " >>> $identity_arn"
    echo
    echo "To continue, please do :"
    echo "  1. Set the appropriate environment variables for the AWS CLI (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_PROFILE etc)"
    echo "  2. Check the contents of ~/.aws/credentials and/or ~/.aws/config (for information on SSO)"
    echo "  3. Ask your cloud infrastructure team for docs on how to access your company's AWS account"
    exit 1
fi

# Handle assumed-role ARNs
if [[ "$identity_arn" == *"assumed-role"* ]]; then
    role_name=$(extract_role_name "$identity_arn")
    echo "Detected assumed role. Resolving permissions for source role: $role_name"
elif [[ "$identity_arn" == *"user"* ]]; then
    role_name=$(echo "$identity_arn" | awk -F'/' '{print $NF}')
    role_name=$(echo "$role_name" | sed 's/"$//')
    echo "Detected IAM user. Resolving permissions for user: $role_name"
else
    echo "Unsupported ARN type. Exiting."
    exit 1
fi

prompt_deployment_type

get_attached_policies() {
    local role_name=$1
    if [[ "$identity_arn" == *"assumed-role"* ]]; then
    	aws iam list-attached-role-policies --role-name "$role_name" --query "AttachedPolicies[].PolicyArn" --output text
    else
	aws iam list-attached-user-policies --user-name "$role_name" --query "AttachedPolicies[].PolicyArn" --output text    
    fi
}

get_inline_policies() {
    local role_name=$1
    if [[ "$identity_arn" == *"assumed-role"* ]]; then
    	aws iam list-role-policies --role-name "$role_name" --query "PolicyNames[]" --output text
    else
        aws iam list-user-policies --user-name "$role_name" --query "PolicyNames[]" --output text
    fi
}

get_policy_actions() {
    local policy_arn=$1
    aws iam get-policy-version --policy-arn "$policy_arn" --version-id $(aws iam list-policy-versions --policy-arn "$policy_arn" --query "Versions[0].VersionId" --output text) --query "PolicyVersion.Document.Statement[].Action" --output text
}

get_inline_policy_actions() {
    local role_name=$1
    local policy_name=$2
    if [[ "$identity_arn" == *"assumed-role"* ]]; then
    	aws iam get-role-policy --role-name "$role_name" --policy-name "$policy_name" --query "PolicyDocument.Statement[].Action" --output text
    else
        aws iam get-user-policy --user-name "$role_name" --policy-name "$policy_name" --query "PolicyDocument.Statement[].Action" --output text
    fi

}

print_table() {
    local header="$1"
    shift
    local policies=("$@")

    # Print header
    printf "%-40s\n" "$header"
    echo "----------------------------------------"

    # Print policies in tabular format
    for policy in "${policies[@]}"; do
        printf "%-40s\n" "$policy"
    done
}



generate_custom_policy() {
    local missing_permissions=("$@") 
    cat <<EOF
$(printf "\"%s\",\n" "${missing_permissions[@]}" | sed '$ s/,$//')
EOF
}

echo

echo "Fetching attached policies for role/user: $role_name..."

attached_policies=$(get_attached_policies "$role_name")

echo 

if [[ -n "$attached_policies" ]]; then
    print_table "Attached Policies" $attached_policies
else
    echo "No attached policies found."
fi

echo

echo "Fetching inline policies for role/user: $role_name..."
inline_policies=$(get_inline_policies "$role_name")

echo 

# Print inline policies in tabular format
if [[ -n "$inline_policies" ]]; then
    print_table "Inline Policies" $inline_policies
else
    echo "No inline policies found."
fi

echo

echo "Fetching missing permissions..."

# Get the permissions granted to the role by those policies
role_actions=""
for policy_arn in $attached_policies; do
    policy_actions=$(get_policy_actions "$policy_arn")
    role_actions+="$policy_actions "
done

for policy_name in $inline_policies; do
    inline_policy_actions=$(get_inline_policy_actions "$role_name" "$policy_name")
    role_actions+="$inline_policy_actions "
done

role_actions_array=($role_actions)

missing_permissions=()
for action in "${required_actions[@]}"; do
    if ! [[ " ${role_actions_array[@]} " =~ " ${action} " ]]; then
        missing_permissions+=("$action")
    fi
done

echo 

# If there are missing permissions, generate a custom policy
if [ ${#missing_permissions[@]} -gt 0 ]; then
    echo "You are missing these required permissions (more info: https://www.devzero.io/docs/admin/install/aws):"
    echo "----------------------------------------"
    generate_custom_policy "${missing_permissions[@]}"
    echo 
    echo "Generating a custom policy in policy.json..."
    echo
    create_policy_json "${missing_permissions[@]}"
    
else
    echo "All required permissions are present in the attached or inline policies."
fi
