### Carbide Provisioning Prerequisites

```bash
### Set Variables
export AWS_IAM_POLICY_NAME=aws-rgs-rancher-mgmt-policy
export AWS_IAM_ROLE_NAME=aws-rgs-rancher-mgmt-role

export AWS_REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

### Create the IAM Policy
aws iam create-policy --policy-name "$AWS_IAM_POLICY_NAME" --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "RancherAWSEC2Permissions",
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:Describe*",
                "ec2:ImportKeyPair",
                "ec2:CreateKeyPair",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteKeyPair",
                "ec2:ModifyInstanceMetadataOptions"
            ],
            "Resource": "*"
        },
        {
            "Sid": "RancherAWSKMSPermissions",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:GenerateDataKeyWithoutPlaintext",
                "kms:Encrypt",
                "kms:DescribeKey",
                "kms:CreateGrant",
                "ec2:DetachVolume",
                "ec2:AttachVolume",
                "ec2:DeleteSnapshot",
                "ec2:DeleteTags",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteVolume",
                "ec2:CreateSnapshot"
            ],
            "Resource": [
              "arn:aws:ec2:'$AWS_REGION':'$AWS_ACCOUNT_ID':volume/*",
              "arn:aws:ec2:'$AWS_REGION':'$AWS_ACCOUNT_ID':instance/*",
              "arn:aws:ec2:'$AWS_REGION':'$AWS_ACCOUNT_ID':snapshot/*",
              "arn:aws:kms:'$AWS_REGION':'$AWS_ACCOUNT_ID':key/*"
            ]
        },
        {
            "Sid": "RancherAWSPassRolePermissions",
            "Effect": "Allow",
            "Action": [
				"iam:PassRole",
				"ec2:RunInstances",
				"ec2:DetachVolume",
				"ec2:AttachVolume",
				"ec2:DeleteSnapshot",
				"ec2:DeleteTags",
				"ec2:CreateTags",
				"ec2:CreateVolume",
				"ec2:DeleteVolume",
				"ec2:CreateSnapshot"
            ],
            "Resource": [
                "arn:aws:ec2:'$AWS_REGION'::image/ami-*",
                "arn:aws:ec2:'$AWS_REGION':'$AWS_ACCOUNT_ID':instance/*",
                "arn:aws:ec2:'$AWS_REGION':'$AWS_ACCOUNT_ID':placement-group/*",
                "arn:aws:ec2:'$AWS_REGION':'$AWS_ACCOUNT_ID':volume/*",
                "arn:aws:ec2:'$AWS_REGION':'$AWS_ACCOUNT_ID':subnet/*",
                "arn:aws:ec2:'$AWS_REGION':'$AWS_ACCOUNT_ID':key-pair/*",
                "arn:aws:ec2:'$AWS_REGION':'$AWS_ACCOUNT_ID':network-interface/*",
                "arn:aws:ec2:'$AWS_REGION':'$AWS_ACCOUNT_ID':security-group/*",
                "arn:aws:iam::'$AWS_ACCOUNT_ID':role/*"
            ]
        },
        {
            "Sid": "RancherAWSEC2ScopedPermissions",
            "Effect": "Allow",
            "Action": [
                "ec2:RebootInstances",
                "ec2:TerminateInstances",
                "ec2:StartInstances",
                "ec2:StopInstances"
            ],
            "Resource": "arn:aws:ec2:'$AWS_REGION':'$AWS_ACCOUNT_ID':instance/*"
        }
    ]
}'

### Create the IAM Role
aws iam create-role --role-name "$AWS_IAM_ROLE_NAME" --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}'

### Attach the IAM Policy to the IAM Role
export AWS_IAM_POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='"$AWS_IAM_POLICY_NAME"'].Arn" --output text)

aws iam attach-role-policy --role-name "$AWS_IAM_ROLE_NAME" --policy-arn "$AWS_IAM_POLICY_ARN"

### Create the IAM Instance Profile
aws iam create-instance-profile --instance-profile-name aws-rgs-rancher-mgmt-profile

### Attach the IAM Role to the IAM Instance Profile
aws iam add-role-to-instance-profile --instance-profile-name aws-rgs-rancher-mgmt-profile --role-name "$AWS_IAM_ROLE_NAME"

### Attach the IAM Instance Profile to the Rancher Manager Nodes
aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].[InstanceId, Tags[?Key==`Name`].Value[], State.Name]' --output table

# Complete this for each applicable EC2 Instance
aws ec2 associate-iam-instance-profile --instance-id YourInstanceID --iam-instance-profile Name=aws-rgs-rancher-mgmt-profile
```
