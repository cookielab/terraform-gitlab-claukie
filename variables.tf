variable "groups_and_projects" {
  description = "List of objects containing either gitlab_group_id or gitlab_group_path and list of gitlab_project_ids or gitlab_project_paths"
  type = list(object({
    gitlab_group_id      = optional(number)
    gitlab_group_path    = optional(string)
    gitlab_project_ids   = optional(list(number), [])
    gitlab_project_paths = optional(list(string), [])
  }))
  default = []
}
variable "token_rotate_before_days" {
  description = "Rotate token no earlier then defined days before expiration"
  type        = number
  default     = 60
}
