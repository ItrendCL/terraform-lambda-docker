# Terraform lambda docker

This is an opinionated terraform module that enforces a few conventions in the building
and naming of docker images used in AWS Lambda functions.

This module does **not** declare Lambda functions. It's best used in conjunction with the
[lambda](https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest)
module.

These conventions are:

1. The `main` workspace creates the ECR repository, other workspaces use it (this
   distinction boils down to resource vs data-source usage).
1. The terraform workspace will be the (mutable) tag of the image.
1. Images are identified by their SHA256 signature.
1. A recomended name for the lambda function will include the workspace. This implies that
   the mapping between environment, workspace, and lambda is one-to-one. This also implies
   that using lambda aliases is not encouraged.
1. Terraform code is expected to live in a folder one-level deeper than the lambda code.

## Usage

Assuming all of the conventions.

```terraform
module "lambda_image" {
  source = "github.com/ItrendCL/terraform-lambda-docker"

  repository = "github-user-or-organization/repository-name"
}
```

Using a multi-lambda repository. This assumes a folder named `a` and a folder named `b`
_next_ to a folder containing the terraform code, as per the last convention above.

```terraform
module "lambda_a" {
  source = "github.com/ItrendCL/terraform-lambda-docker"

  repository = "github-user-or-organization/repository-name"
  suffix     = "a"
}

module "lambda_a" {
  source = "github.com/ItrendCL/terraform-lambda-docker"

  repository = "github-user-or-organization/repository-name"
  suffix     = "b"
}
```

Using all of the parameters, and not assuming the last convention.

```terraform
module "lambda_a" {
  source = "github.com/ItrendCL/terraform-lambda-docker"

  repository = "github-user-or-organization/repository-name"
  suffix     = "some-suffix"
  path       = "." // use this folder as docker context

  image_expiration_days = null // untagged images won't expire from the ECR
  image_build_args      = { VERSION = "1.2.3" }
  image_dockerfile      = "production.Dockerfile"
}
```
