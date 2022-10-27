// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

resource "aws_iam_role" "codepipeline_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  path               = "/"
}

resource "aws_iam_policy" "codepipeline_policy" {
  description = "Policy to allow codepipeline to execute"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject", "s3:GetObjectVersion", "s3:PutObject",
        "s3:GetBucketVersioning"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.artifact_bucket.arn}/*"
    },
    {
      "Action" : [
        "codebuild:StartBuild", "codebuild:BatchGetBuilds",
        "cloudformation:*",
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action" : [
        "ecs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action" : [
        "codecommit:CancelUploadArchive",
        "codecommit:GetBranch",
        "codecommit:GetCommit",
        "codecommit:GetUploadArchiveStatus",
        "codecommit:UploadArchive"
      ],
      "Effect": "Allow",
      "Resource": "${aws_codecommit_repository.source_repo.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline-attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

resource "aws_s3_bucket" "artifact_bucket" {
  #checkov:skip=CKV_AWS_19: "Ensure all data stored in the S3 bucket is securely encrypted at rest"
  #checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default"
  #checkov:skip=CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled"
  #checkov:skip=CKV2_AWS_6: "Ensure that S3 bucket has a Public Access block"
}

# CodePipeline

resource "aws_codepipeline" "pipeline" {
  depends_on = [
    aws_codebuild_project.codebuild,
    aws_codecommit_repository.source_repo
  ]
  name     = "${var.REPOSITORY_NAME}-${var.REPOSITORY_BRANCH_NAME}-Pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeCommit"
      output_artifacts = ["SourceOutput"]
      run_order        = 1
      configuration = {
        RepositoryName       = var.REPOSITORY_NAME
        BranchName           = var.REPOSITORY_BRANCH_NAME
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      run_order        = 1
      configuration = {
        ProjectName = aws_codebuild_project.codebuild.id
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      version         = "1"
      provider        = "ECS"
      run_order       = 1
      input_artifacts = ["BuildOutput"]
      configuration = {
        ClusterName       = "${var.stack}-Cluster"
        ServiceName       = "${var.stack}-Service"
        FileName          = "imagedefinitions.json"
        DeploymentTimeout = "15"
      }
    }
  }
  #checkov:skip=CKV_AWS_219: "Ensure Code Pipeline Artifact store is using a KMS CMK"
}

output "pipeline_url" {
  value = "https://console.aws.amazon.com/codepipeline/home?region=${var.AWS_REGION}#/view/${aws_codepipeline.pipeline.id}"
}