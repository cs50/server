# Elastic Beanstalk

## IAM Policy

    {
        "Statement": [
            {
                "Action": "autoscaling:*",
                "Effect": "Allow",
                "Resource": "*"
            },
            {
                "Action": "cloudformation:*",
                "Effect": "Allow",
                "Resource": "arn:aws:cloudformation:[region]:[accountid]:*"
            },
            {
                "Action": [
                    "ec2:DescribeImages",
                    "ec2:DescribeInstances",
                    "ec2:DescribeKeyPairs",
                    "ec2:DescribeSecurityGroups",
                    "ec2:DescribeSubnets",
                    "ec2:DescribeVpcs"
                ],
                "Effect": "Allow",
                "Resource": "*"
            },
            {
                "Action": [
                    "elasticbeanstalk:CreateApplicationVersion",
                    "elasticbeanstalk:DescribeEnvironments",
                    "elasticbeanstalk:DeleteApplicationVersion",
                    "elasticbeanstalk:UpdateEnvironment"
                ],
                "Effect": "Allow",
                "Resource": "*"
            },
            {
                "Action": "elasticloadbalancing:*",
                "Effect": "Allow",
                "Resource": "*"
            },
            {
                "Action": "s3:*",
                "Resource": [
                    "arn:aws:s3:::elasticbeanstalk-[region]-[accountid]",
                    "arn:aws:s3:::elasticbeanstalk-[region]-[accountid]/",
                    "arn:aws:s3:::elasticbeanstalk-[region]-[accountid]/*"
                ],
                "Effect": "Allow"
            },
            {
                "Action": "s3:Get*",
                "Resource": "arn:aws:s3:::elasticbeanstalk-*/*",
                "Effect": "Allow"
            },
            {
                "Action": [
                    "s3:GetObject",
                    "s3:PutObject"
                ],
                "Effect": "Allow",
                "Resource": "arn:aws:s3:::[s3-bucket]/*"
            },
            {
                "Action": "s3:ListBucket",
                "Effect": "Allow",
                "Resource": "arn:aws:s3:::[s3-bucket]"
            },
            {
                "Action": [
                    "sns:CreateTopic",
                    "sns:GetTopicAttributes",
                    "sns:ListSubscriptionsByTopic",
                    "sns:Subscribe"
                ],
                "Effect": "Allow",
                "Resource": "arn:aws:sns:[region]:[accountid]:*"
            }
        ]
    }
