### Create the IAM Policy
aws iam create-policy --policy-name aws-rgs-rancher-mgmt-policy --policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:*",
        "kms:*",
        "ec2:*",
        "autoscaling:*",
        "elasticloadbalancing:*",
        "ecr:*"
      ],
      "Resource": "*"
    }
  ]
}'

### Create the IAM Role
aws iam create-role --role-name aws-rgs-rancher-mgmt-role --assume-role-policy-document '{
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
iam_policy_arn=$(aws iam list-policies --query 'Policies[?PolicyName==`aws-rgs-rancher-mgmt-policy`].Arn' --output text)

aws iam attach-role-policy --role-name aws-rgs-rancher-mgmt-role --policy-arn $iam_policy_arn

### Create the IAM Instance Profile
aws iam create-instance-profile --instance-profile-name aws-rgs-rancher-mgmt-profile

### Attach the IAM Role to the IAM Instance Profile
aws iam add-role-to-instance-profile --instance-profile-name aws-rgs-rancher-mgmt-profile --role-name aws-rgs-rancher-mgmt-role

### Attach the IAM Instance Profile to the Rancher Manager Nodes
aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].[InstanceId, Tags[?Key==`Name`].Value[], State.Name]' --output table

# do this for each rancher manager node (usually three nodes)
aws ec2 associate-iam-instance-profile --instance-id YourInstanceID --iam-instance-profile Name=aws-rgs-rancher-mgmt-profile
