# {{ .example_name }}

{{ .description }}

## Usage

```hcl
module "{{ .module_name }}" {
  source = "../../modules/{{ .module_name }}"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| result | Output from the {{ .module_name }} module |
