locals {
  # These files are kept tightly in sync with the backend config
  managed_files = toset([
    "providers.tf",
  ])
}

# Leave a script for properly initializing when running locally
resource "local_file" "initialization_script" {
  filename        = "${local.path}/init.sh"
  file_permission = "0755"
  content         = <<-EOF
  #!/bin/bash

  set -e
  terraform init \
    --backend-config=../shared/config/backend.tfvars \
    --backend-config=key=terraform.tfstate.$(basename $(pwd))
  EOF
}

resource "local_file" "managed_files" {
  for_each        = local.managed_files
  filename        = "${local.path}/${each.key}"
  file_permission = "0644"
  content = templatefile("${path.module}/templates/${each.key}-template",
    { name = var.name }
  )
}

resource "local_file" "main-tf" {
  lifecycle {
    ignore_changes = all
  }
  filename        = "${local.path}/${var.name}.tf"
  file_permission = "0644"
  content = templatefile("${path.module}/templates/main.tf-template",
    { name = var.name }
  )
}

resource "local_file" "variables-tf" {
  lifecycle {
    ignore_changes = all
  }
  filename        = "${local.path}/variables.tf"
  file_permission = "0644"
  content = templatefile("${path.module}/templates/variables.tf-template",
    { name = var.name }
  )
}
