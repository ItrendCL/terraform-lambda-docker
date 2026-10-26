variable "repository" {
  type        = string
  nullable    = false
  description = "The Github repository which holds the lambda declarations"
}

variable "suffix" {
  type        = string
  nullable    = false
  default     = ""
  description = "The suffix over the repository, used to identify a single lambda inside a repository with possibly many lambdas"
}

variable "path" {
  type        = string
  nullable    = true
  default     = null
  description = "The path to the lambda function's root; if omitted, it defaults to '../{suffix}'"
}

variable "image_expiration_days" {
  type        = number
  nullable    = true
  default     = 14
  description = "The days an untagged image survives in ECR; set to null to never expire. Ignored when lifecycle_policy is set"
}

variable "lifecycle_policy" {
  type        = string
  nullable    = true
  default     = null
  description = "ECR lifecycle policy JSON for the repository; replaces the image_expiration_days rule when set. Only applied where this module creates the ECR repository"
}

variable "image_build_args" {
  type        = map(string)
  default     = {}
  description = "Arguments to pass to the image at build time"
}

variable "image_dockerfile" {
  type        = string
  default     = "Dockerfile"
  description = "The path to the Dockerfile"
}

variable "create_ecr" {
  type        = bool
  description = "Whether to create the ECR repository"
  default     = null
}
