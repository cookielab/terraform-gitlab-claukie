locals {
  groups_by_path = {
    for k, g in local.groups :
    k => g
    if g.gitlab_group_path != null
  }

  groups_by_id = {
    for k, g in local.groups :
    k => g
    if g.gitlab_group_id != null
  }

  projects_flat = flatten([
    for group_key, g in local.groups : concat(
      [
        for pid in g.gitlab_project_ids : {
          key        = tostring(pid)
          group_key  = group_key
          project_id = tostring(pid)
          by_path    = false
        }
      ],
      [
        for ppath in g.gitlab_project_paths : {
          key          = ppath
          group_key    = group_key
          project_path = ppath
          by_path      = true
        }
      ]
    )
  ])

  projects_map = { for p in local.projects_flat : p.key => p }

  projects_by_id_map = {
    for k, p in local.projects_map :
    k => p
    if !p.by_path
  }

  projects_by_path_map = {
    for k, p in local.projects_map :
    k => p
    if p.by_path
  }

  resolved_groups = merge(
    { for k, v in data.gitlab_group.by_path : k => v },
    { for k, v in data.gitlab_group.by_id : k => v }
  )

  resolved_projects = merge(
    { for k, v in data.gitlab_project.by_id : k => { project = v, group_key = local.projects_by_id_map[k].group_key } },
    { for k, v in data.gitlab_project.by_path : k => { project = v, group_key = local.projects_by_path_map[k].group_key } }
  )
  groups = {
    for g in var.groups_and_projects :
    coalesce(g.gitlab_group_path, tostring(g.gitlab_group_id)) => g
  }
}

data "gitlab_group" "by_path" {
  for_each  = local.groups_by_path
  full_path = each.value.gitlab_group_path
}

data "gitlab_group" "by_id" {
  for_each = local.groups_by_id
  group_id = each.value.gitlab_group_id
}

data "gitlab_project" "by_id" {
  for_each = local.projects_by_id_map
  id       = each.value.project_id
}

data "gitlab_project" "by_path" {
  for_each            = local.projects_by_path_map
  path_with_namespace = each.value.project_path
}

resource "gitlab_group_service_account" "this" {
  for_each = local.resolved_groups

  group    = each.value.id
  name     = "claukie ${each.value.name}"
  username = "claukie-${each.value.path}"
}

resource "gitlab_group_service_account_access_token" "this" {
  for_each = local.resolved_groups

  group   = each.value.id
  user_id = gitlab_group_service_account.this[each.key].service_account_id
  name    = "Claukie service account access token"

  rotation_configuration = {
    expiration_days    = 365
    rotate_before_days = var.token_rotate_before_days
  }

  scopes = ["api"]
}

resource "gitlab_project_membership" "this" {
  for_each = local.resolved_projects

  project      = each.value.project.id
  user_id      = gitlab_group_service_account.this[each.value.group_key].service_account_id
  access_level = "developer"
}

resource "gitlab_project_variable" "this" {
  for_each = local.resolved_projects

  raw               = true
  hidden            = true
  masked            = true
  protected         = false
  key               = "CLAUKIE_GITLAB_TOKEN"
  value             = gitlab_group_service_account_access_token.this[each.value.group_key].token
  description       = "Claukie gitlab group service account access token"
  project           = each.value.project.id
  variable_type     = "env_var"
  environment_scope = "*"
}
