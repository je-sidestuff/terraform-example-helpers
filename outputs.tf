output "random_value" {
  value = data.external.latched_random_data.result.random_value
}
