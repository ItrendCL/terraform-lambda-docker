terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.22.0"
    }
  }
}

# Get region and account ID
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Define the ECR repository
locals {
  repository_name  = trimsuffix(lower(join("/", [var.repository, var.suffix])), "/")
  context_path     = trimsuffix(var.path == null ? "../${var.suffix}" : var.path, "/")
  is_dev_workspace = terraform.workspace == "dev"
  create_ecr_final = var.create_ecr != null ? var.create_ecr : local.is_dev_workspace
}

resource "aws_ecr_repository" "this" {
  count = local.create_ecr_final ? 1 : 0

  image_scanning_configuration {
    scan_on_push = true
  }

  name = local.repository_name
}

data "aws_ecr_repository" "this" {
  count = local.create_ecr_final ? 0 : 1

  name = local.repository_name
}

resource "aws_ecr_lifecycle_policy" "expire_untagged" {
  count = local.create_ecr_final && var.image_expiration_days != null ? 1 : 0

  repository = aws_ecr_repository.this[0].name
  policy = jsonencode({
    rules = [{
      rulePriority = 1,
      description  = "Expire images older than ${var.image_expiration_days} days",
      selection = {
        tagStatus   = "untagged",
        countType   = "sinceImagePushed",
        countUnit   = "days",
        countNumber = var.image_expiration_days
      },
      action = {
        type = "expire"
      }
    }]
  })
}

# Build and push the docker image
data "aws_ecr_authorization_token" "token" {}

provider "docker" {
  registry_auth {
    address = join(".", [
      "${data.aws_caller_identity.current.account_id}",
      "dkr.ecr",
      data.aws_region.current.name,
      "amazonaws.com"
    ])
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

resource "null_resource" "changes" {
  # This resource detects changes in the docker context folder
  triggers = {
    folder_hash = sha1(join(
      "",
      [for file in fileset(local.context_path, "**") : join(
        "@",
        ["${local.context_path}/${file}", filesha1("${local.context_path}/${file}")
      ])]
    ))
  }
}

resource "docker_registry_image" "this" {
  name = join(
    ":",
    [
      local.create_ecr
      ? aws_ecr_repository.this[0].repository_url
      : data.aws_ecr_repository.this[0].repository_url,
      terraform.workspace
    ]
  )

  build {
    context    = local.context_path
    build_args = var.image_build_args
    dockerfile = var.image_dockerfile
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.changes.id
    ]
  }
}
