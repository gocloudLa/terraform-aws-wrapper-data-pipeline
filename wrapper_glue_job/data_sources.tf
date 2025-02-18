data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_kms_key" "glue_job" {
  key_id = var.kms_arn
}

data "aws_iam_policy_document" "this" {
  count = var.create ? 1 : 0

  source_policy_documents = [jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSServices",
        Effect = "Allow",
        Action = [
          "glue:*",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:GetBucketAcl",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeRouteTables",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcAttribute",
          "iam:ListRolePolicies",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "cloudwatch:PutMetricData"
        ],
        Resource = "*"
      },
      {
        Sid    = "S3CreateBucketsGlue",
        Effect = "Allow",
        Action = [
          "s3:CreateBucket"
        ],
        Resource = ["arn:aws:s3:::aws-glue-*"]
      },
      {
        Sid    = "S3ObjectsBucketsGlue",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = ["arn:aws:s3:::aws-glue-*/*", "arn:aws:s3:::*/*aws-glue-*/*"]
      },
      {
        Sid    = "S3GetObjectsBucketsGlue",
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = ["arn:aws:s3:::crawler-public*", "arn:aws:s3:::aws-glue-*"]
      },
      {
        Sid    = "LogGroups",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = ["arn:aws:logs:*:*:*:/aws-glue/*"]
      },
      {
        Sid    = "Tags",
        Effect = "Allow",
        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        Condition = {
          "ForAllValues:StringEquals" = {
            "aws:TagKeys" = ["aws-glue-service-resource"]
          }
        },
        Resource = ["arn:aws:ec2:*:*:network-interface/*", "arn:aws:ec2:*:*:security-group/*", "arn:aws:ec2:*:*:instance/*", ]
      },
      {
        Sid    = "KMS",
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = data.aws_kms_key.glue_job.arn
      },
    ]
  })]
  override_policy_documents = [jsonencode(var.role_custom_policy)]
}
