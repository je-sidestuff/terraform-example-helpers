# {{ .module_name }}
# {{ .description }}

resource "null_resource" "example" {
  triggers = {
    always_run = timestamp()
  }
}
