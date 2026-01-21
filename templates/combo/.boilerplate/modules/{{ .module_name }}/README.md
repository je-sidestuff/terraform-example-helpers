# {{ .module_name }}

{{ .description }}

## Usage

```hcl
module "{{ .module_name }}" {
  source = "path/to/modules/{{ .module_name }}"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| null | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| null | >= 3.0 |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the null resource |
