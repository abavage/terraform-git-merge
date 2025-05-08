variable "git_token" {
  type    = string
  default = ""
  description = "sourced from an env var export TF_VAR_git_token"
}

variable "git_repo" {
  type    = string
  default = "terraform-pr-test"
  description = "name of the git repo"
}
