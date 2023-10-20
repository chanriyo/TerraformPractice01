# ECR作成(ビルド前ベース用)
resource "aws_ecr_repository" "JdkBaseRepo" {
  name = "base-amazoncorretto"
}

resource "aws_ecr_lifecycle_policy" "JdkBaseRepoPolicy" {
  repository = aws_ecr_repository.JdkBaseRepo.name

  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 30 release tagged images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["release"],
          "countType": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
EOF
}

resource "aws_ecr_repository" "GradleBaseRepo" {
  name = "base-gradle"
}

resource "aws_ecr_lifecycle_policy" "GradleBaseRepoPolicy" {
  repository = aws_ecr_repository.GradleBaseRepo.name

  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 30 release tagged images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["release"],
          "countType": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
EOF
}

resource "aws_ecr_repository" "NginxBaseRepo" {
  name = "base-nginx"
}

resource "aws_ecr_lifecycle_policy" "NginxBaseRepoPolicy" {
  repository = aws_ecr_repository.NginxBaseRepo.name

  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 30 release tagged images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["release"],
          "countType": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
EOF
}


# ECR作成(ビルド後保存用)
resource "aws_ecr_repository" "JdkImagesRepo" {
  name = "jdk-images-repo"
}

resource "aws_ecr_lifecycle_policy" "JdkImagesRepoPolicy" {
  repository = aws_ecr_repository.JdkImagesRepo.name

  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 30 release tagged images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["release"],
          "countType": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
EOF
}

resource "aws_ecr_repository" "NginxImagesRepo" {
  name = "nginx-images-repo"
}

resource "aws_ecr_lifecycle_policy" "NginxImagesRepoPolicy" {
  repository = aws_ecr_repository.NginxImagesRepo.name

  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 30 release tagged images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["release"],
          "countType": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
EOF
}

# CodeBuild作成
data "aws_iam_policy_document" "iam_codebuild" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
  }
}

module "codebuild_role" {
  source     = "./modules/iam_role"
  name       = "codebuild"
  identifier = "codebuild.amazonaws.com"
  policy     = data.aws_iam_policy_document.iam_codebuild.json
}

resource "aws_codebuild_project" "build_project" {
  name         = "build_project"
  service_role = module.codebuild_role.iam_role_arn

  source {
    type = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/ubuntu-base:14.04"
    privileged_mode = true
  }

}

# CodeCommit作成
resource "aws_codecommit_repository" "app" {
  repository_name = "AppRepository"
  description     = "This is the Sample App Repository"
}

resource "aws_codecommit_repository" "nginx" {
  repository_name = "NginxRepository"
  description     = "This is the Sample Nginx Repository"
}

