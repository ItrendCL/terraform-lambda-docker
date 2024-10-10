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
    local.create_ecr_final
    ? aws_ecr_repository.this[0].repository_url
    : data.aws_ecr_repository.this[0].repository_url,
    "@",
    docker_registry_image.this.sha256_digest
  ])
}

output "lambda_name" {
  value = replace(local.repository_name, "/", "-")
}

output "lambda_name_recomended" {
  value = join("-", [
    replace(local.repository_name, "/", "-"),
    terraform.workspace
  ])
}

output "ecr_repository" {
  value = local.create_ecr_final ? aws_ecr_repository.this[0] : data.aws_ecr_repository.this[0]
}
