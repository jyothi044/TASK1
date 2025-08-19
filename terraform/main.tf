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

resource "neon_endpoint" "branch_endpoint" {
  project_id = data.neon_project.existing_project.id
  branch_id  = "main"   # use your existing branch name
  type       = "read_write"
}

