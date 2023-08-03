# We need the Org GUID to describe spaces
data "cloudfoundry_org" "org" {
  name = var.org_name
}

data "cloudfoundry_asg" "asgs" {
  for_each = toset(var.asgs)
  name     = each.key
}

# Ensure the space exists and is configured as expected
resource "cloudfoundry_space" "space" {
  name = var.name
  org  = data.cloudfoundry_org.org.id

  # Disallow SSH access for the special name production
  allow_ssh = var.allow_ssh

  asgs = [for d in var.asgs : d]

  # Until the CF provider can properly handle ASGs, we're handling removal of the public_egress ASG manually outside of Terraform.
  # https://github.com/cloudfoundry-community/terraform-provider-cloudfoundry/issues/405
  lifecycle {
    ignore_changes = [
      asgs,
    ]
  }
}

# Commented out until we are properly addressing the TODO
# resource "cloudfoundry_space_users" "space_permissions" {
#   space      = cloudfoundry_space.space.id
#   developers = var.developers # TODO: Include the space-deployer username from the service-key!
#   managers   = var.managers
# }
