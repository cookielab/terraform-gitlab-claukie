# claukie

Terraform module for provisioning [Claukie](https://gitlab.cookielab.io/general/claukie) — a GitLab bot that performs automated code reviews on merge requests using Claude AI.

## What this module creates

For each entry in `groups_and_projects`, the module creates:

- **Group access token** — a long-lived GitLab group-level API token (365 days, auto-rotated 60 days before expiry) with `api` scope; the token inherits the group's permissions and therefore has access to all projects within that group
- **CI/CD variable** (`CLAUKIE_GITLAB_TOKEN`) — the access token is injected into each listed project's CI/CD variables so pipelines can authenticate the bot

## Usage

Groups and projects can be referenced either by numeric ID or by path:

```hcl
module "claukie" {
  source = "./modules/claukie"

  groups_and_projects = [
    {
      gitlab_group_id  = 42
      gitlab_project_ids = [101, 102]
    },
    {
      gitlab_group_path    = "my-group"
      gitlab_project_paths = ["my-group/project-a", "my-group/project-b"]
    },
  ]
}
```

Each entry must specify either `gitlab_group_id` or `gitlab_group_path` (not both). Projects follow the same rule — use IDs or paths, not a mix within a single entry.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0, < 2.0.0 |
| <a name="requirement_gitlab"></a> [gitlab](#requirement\_gitlab) | >= 18.6.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_gitlab"></a> [gitlab](#provider\_gitlab) | >= 18.6.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [gitlab_group_access_token.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/group_access_token) | resource |
| [gitlab_project_variable.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_group.by_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/data-sources/group) | data source |
| [gitlab_group.by_path](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/data-sources/group) | data source |
| [gitlab_project.by_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/data-sources/project) | data source |
| [gitlab_project.by_path](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_groups_and_projects"></a> [groups\_and\_projects](#input\_groups\_and\_projects) | List of objects containing either gitlab\_group\_id or gitlab\_group\_path and list of gitlab\_project\_ids or gitlab\_project\_paths | <pre>list(object({<br/>    gitlab_group_id      = optional(number)<br/>    gitlab_group_path    = optional(string)<br/>    gitlab_project_ids   = optional(list(number), [])<br/>    gitlab_project_paths = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_token_rotate_before_days"></a> [token\_rotate\_before\_days](#input\_token\_rotate\_before\_days) | Rotate token no earlier then defined days before expiration | `number` | `60` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
