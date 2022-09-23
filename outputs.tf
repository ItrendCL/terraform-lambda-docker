# Re-export inputs
output "repository" {
  value = var.repository
}

output "suffix" {
  value = var.suffix
}

output "path" {
  value = var.path
}

output "image_expiration_days" {
  value = var.image_expiration_days
}

output "image_build_args" {
  value = var.image_build_args
}

output "image_dockerfile" {
  value = var.image_dockerfile
}

# Export image URI and proposed generated lambda name
output "image_uri" {
  value = join("", [
    aws_ecr_repository.this.repository_url,
    "@",
    docker_registry_image.this.sha256_digest
  ])
}

output "lambda_name" {
  value = join("-", [
    replace(local.repository_name, "/", "-"),
    terraform.workspace
  ])
}
