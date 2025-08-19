terraform {
  required_providers {
    neon = {
      source  = "kislerdm/neon"
      version = "0.9.0"
    }
  }
}

provider "neon" {
  api_key = "napi_k6ldlo9x9ttcbcqpfk252gtpk9hmadf1ya2igbqfj2v5d7y6smgf6gg1p4kc7346"
}

# Reference existing project by ID
data "neon_project" "existing_project" {
  id = "silent-wind-76204907"
}

# Variable to control branch creation
variable "create_new_branch" {
  description = "Whether to create a new branch or use existing main"
  type        = bool
  default     = false
}

# Only create a branch if create_new_branch = true
resource "neon_branch" "maybe_new_branch" {
  count      = var.create_new_branch ? 1 : 0
  project_id = data.neon_project.existing_project.id
  name       = "main"
}

# Create an endpoint for the branch (use existing main if branch not created)
resource "neon_endpoint" "branch_endpoint" {
  project_id = data.neon_project.existing_project.id
  branch_id  = var.create_new_branch ? neon_branch.maybe_new_branch[0].id : "main"
  type       = "read_write"
}