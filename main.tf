data "external" "latched_random_data" {
  program = ["bash", "${path.module}/scripts/external_latched_random.sh"]

  query = {
    example_seed = var.example_seed
  }
}
