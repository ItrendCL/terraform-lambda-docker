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
  description = "The days an untagged image survives in ECR; set to null to never expire"
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
