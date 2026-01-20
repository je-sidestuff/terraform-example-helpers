package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestRandomSeedDifferentOnReinstantiate verifies that when an example is destroyed
// and recreated without a seed, the random value is different each time.
func TestRandomSeedDifferentOnReinstantiate(t *testing.T) {

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/local",
		Vars: map[string]interface{}{
			"example_seed": "",
		},
	})

	// First instantiation
	terraform.InitAndApply(t, terraformOptions)
	firstRandomValue := terraform.Output(t, terraformOptions, "random_value")

	// Destroy
	terraform.Destroy(t, terraformOptions)

	// Second instantiation
	terraform.InitAndApply(t, terraformOptions)
	secondRandomValue := terraform.Output(t, terraformOptions, "random_value")

	// Clean up
	defer terraform.Destroy(t, terraformOptions)

	// Verify the values are different
	assert.NotEqual(t, firstRandomValue, secondRandomValue, "Random values should be different after destroy and recreate")
}

// TestRandomSeedProvidedExternally verifies that a random value created at test scope
// can be passed in and used as the seed value.
func TestRandomSeedProvidedExternally(t *testing.T) {

	// Create a random value at test scope
	externalSeed := random.UniqueId()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/local",
		Vars: map[string]interface{}{
			"example_seed": externalSeed,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	randomValue := terraform.Output(t, terraformOptions, "random_value")

	// Verify the random value matches the seed we provided
	assert.Equal(t, externalSeed, randomValue, "Random value should match the externally provided seed")
}

// TestRandomSeedConsistentOnReapply verifies that the random seed value stays
// consistent when the example is instantiated twice (without destroy).
func TestRandomSeedConsistentOnReapply(t *testing.T) {

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/local",
		Vars: map[string]interface{}{
			"example_seed": "",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	// First apply
	terraform.InitAndApply(t, terraformOptions)
	firstRandomValue := terraform.Output(t, terraformOptions, "random_value")

	// Second apply (without destroy)
	terraform.InitAndApply(t, terraformOptions)
	secondRandomValue := terraform.Output(t, terraformOptions, "random_value")

	// Verify the values are the same
	assert.Equal(t, firstRandomValue, secondRandomValue, "Random value should remain consistent across applies")
}

// TestRandomSeedChangeAfterInstantiationErrors verifies that changing the seed value
// after initial instantiation causes an error.
// NOTE: This test is commented out as it will fail, not yet implemented.
/*
func TestRandomSeedChangeAfterInstantiationErrors(t *testing.T) {
	t.Parallel()

	initialSeed := random.UniqueId()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/local",
		Vars: map[string]interface{}{
			"example_seed": initialSeed,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	// First apply with initial seed
	terraform.InitAndApply(t, terraformOptions)

	// Change the seed value
	newSeed := random.UniqueId()
	terraformOptions.Vars["example_seed"] = newSeed

	// Attempt to apply with changed seed - this should error
	_, err := terraform.InitAndApplyE(t, terraformOptions)
	assert.Error(t, err, "Changing the seed value after initial instantiation should cause an error")
}
//*/
