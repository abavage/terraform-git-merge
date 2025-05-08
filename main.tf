provider "github" {
 token = var.git_token
 #owner = "your_org_name"
}

resource "aws_efs_file_system" "cluster_efs" {
  encrypted      = true

  tags = {
    Name = "cpaas-dc1002"
  }
}

data "aws_efs_file_system" "selected" {
  tags = {
    Name = "cpaas-dc1002"
  }
  depends_on = [
    aws_efs_file_system.cluster_efs
  ]
}

output "efsid" {
  value = data.aws_efs_file_system.selected.id
}


locals {
  original_content = file("${path.module}/terraform-pr-test/efs.yaml")
  updated_content = replace(local.original_content, "/name: efs-[a-zA-Z0-9]+/", "name: ${data.aws_efs_file_system.selected.id}")
}

output "thevalue" {
  value = local.updated_content
}

#resource "random_string" "string" {
#  length = 5
#  special = false
#}

#output "random_string" {
#  value = random_string.string.id
#}

#resource "null_resource" "random_string" {
#  provisioner "local-exec" {
#    command = "uuidgen  | awk -F- '{print tolower ($2)}'"
#  }
#
#  triggers = {
#    always_run = "${timestamp()}"
#  }
#}


#output "random_string" {
#  value = null_resource.random_string.id
#}

data "external" "random_string" {
  program = ["bash", "-c", "scripts/random.sh"]
}

output "random_string" {
  value = data.external.random_string.result.random_string
}

resource "github_branch" "feature" {
  repository = var.git_repo
  branch     = "testa-${data.external.random_string.result.random_string}"
  source_branch = "main"
}

resource "github_repository_file" "udpate_file" {
  repository = var.git_repo
  branch     = github_branch.feature.branch
  file       = "efs.yaml"
  content    = local.updated_content
  commit_message = "Update efs.yaml"
  overwrite_on_create = true
}

resource "github_repository_pull_request" "pr" {
  base_repository = var.git_repo
  base_ref        = "main"
  head_ref        = github_branch.feature.branch
  title           = "Automated PR - ${data.external.random_string.result.random_string}"
  body            = "PR by terraform - ${data.external.random_string.result.random_string}"
  depends_on = [
    github_repository_file.udpate_file
 ]

}
