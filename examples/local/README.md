# Local Example

This example demonstrates how to use the `example_helpers` module with a provided seed value.

## Usage

```hcl
module "example_helpers" {
  source = "../.."

  example_seed = "stuff"
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| example_seed | A seed value to use for generating a random value | `string` | No |

## Outputs

| Name | Description |
|------|-------------|
| random_value | The generated random value from the module |

## Running This Example

```bash
terraform init
terraform plan
terraform apply
```
