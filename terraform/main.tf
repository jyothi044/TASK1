terraform {
  required_providers {
    neon = {
      source  = "kislerdm/neon"
      version = "0.9.0"
    }
  }
}

provider "neon" {
  api_key ="napi_k6ldlo9x9ttcbcqpfk252gtpk9hmadf1ya2igbqfj2v5d7y6smgf6gg1p4kc7346"
}

# Reference existing project by ID
data "neon_project" "existing_project" {
  id = "silent-wind-76204907"  
}

# Reference existing default branch "main"
data "neon_branch" "main_branch" {
  project_id = data.neon_project.existing_project.id
  name       = "main"
}

# Create an endpoint for the existing branch
resource "neon_endpoint" "branch_endpoint" {
  project_id = data.neon_project.existing_project.id
  branch_id  = data.neon_branch.main_branch.id
  type       = "read_write"
}
