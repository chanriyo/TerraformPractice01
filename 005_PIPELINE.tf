# CODEPIPELINE

data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:UploadArchive",
      "codecommit:GetUploadArchiveStatus",
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "iam:PassRole",
    ]
  }
}
module "codepipeline_role" {
  source     = "./modules/iam_role"
  name       = "codepipeline"
  identifier = "codepipeline.amazonaws.com"
  policy     = data.aws_iam_policy_document.codepipeline.json
}

resource "aws_s3_bucket" "artifact" {
  bucket = "pipeline-test-artifact"
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.artifact.id

  rule {
    id      = "expire_after_180_days"
    status  = "Enabled"

    expiration {
      days = 180
    }
  }
}

resource "aws_codepipeline" "example" {
  name     = "example"
  role_arn = module.codepipeline_role.iam_role_arn

  stage {
    name = "Source"

    action {
        name             = "Source1"
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeCommit"
        version          = 1
        output_artifacts = ["Source1"]
        configuration = {
          RepositoryName       = aws_codecommit_repository.nginx.repository_name
          BranchName           = "master"
          # OutputArtifactFormat = "CODE_ZIP"
        }
    }

    action {
        name             = "Source2"
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeCommit"
        version          = 1
        output_artifacts = ["Source2"]
        configuration = {
          RepositoryName       = aws_codecommit_repository.app.repository_name
          BranchName           = "master"
          # OutputArtifactFormat = "CODE_ZIP"
        }
    }

  }


  stage {
    name = "Build_Nginx"

    action {
      name             = "Build1"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      input_artifacts  = ["Source1"]
      output_artifacts = ["Build1"]

      configuration = {
        ProjectName = aws_codebuild_project.build_project.id
      }
    }
  }

  stage {
    name = "Build_JDK"

    action {
      name             = "Build2"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      input_artifacts  = ["Source2"]
      output_artifacts = ["Build2"]

      configuration = {
        ProjectName = aws_codebuild_project.build_project.id
      }
    }
  }

  stage {
    name = "Deploy1"

    action {
      name            = "Deploy1"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = 1
      input_artifacts = ["Build1"]

      configuration = {
        ClusterName = aws_ecs_cluster.example.name
        ServiceName = aws_ecs_service.example.name
        FileName    = "imagedefinitions_NGINX.json"
      }
    }
  }

  stage {
    name = "Deploy2"

    action {
      name            = "Deploy2"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = 1
      input_artifacts = ["Build2"]

      configuration = {
        ClusterName = aws_ecs_cluster.example.name
        ServiceName = aws_ecs_service.example.name
        FileName    = "imagedefinitions_JDK.json"
      }
    }
  }

  artifact_store {
    location = aws_s3_bucket.artifact.id
    type     = "S3"
  }
}
