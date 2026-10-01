// Terraform: create GitHub OIDC provider and an IAM role for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  provider = aws.us_east_1
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions" {
  provider = aws.us_east_1
  name = "github-actions-role-shogroo"

  # GitHub OIDC `sub` examples when using environment: production:
  #   repo:firstlesson2020/shogroo:environment:production
  # Do NOT put owner/repo numeric IDs inside `sub` — use repository_id claim instead.
  # Wildcards require StringLike (StringEquals is exact match only).
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud"            = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:repository_id" = "1395537535"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:firstlesson2020/shogroo:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_policy" {
  provider = aws.us_east_1
  name     = "github-actions-policy-shogroo"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:CreateBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::shogroo.com",
          "arn:aws:s3:::shogroo.com/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetDistribution",
          "cloudfront:GetDistributionConfig",
          "cloudfront:ListDistributions",
          "cloudfront:CreateDistribution",
          "cloudfront:UpdateDistribution",
          "cloudfront:DeleteDistribution"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "acm:RequestCertificate",
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:GetCertificate",
          "acm:DeleteCertificate"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:GetChange",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:GetHostedZone"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sts:GetCallerIdentity"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_minimal" {
  provider   = aws.us_east_1
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}
