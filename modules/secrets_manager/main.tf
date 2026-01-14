# Create the Secret metadata (the container)
resource "aws_secretsmanager_secret" "this" {
  for_each = toset(var.sensitive_keys)

  name        = "${var.project_name}/${var.environment}/${each.key}"
  description = "Managed by Terraform: ${each.key}"

  recovery_window_in_days = 7 # Allows restoration if accidentally deleted

  tags = {
    Name        = "${var.project_name}-${each.key}"
    Environment = var.environment
  }
}

# Create the initial value for each secret
resource "aws_secretsmanager_secret_version" "this" {
  for_each  = aws_secretsmanager_secret.this
  secret_id = each.value.id

  # Logic: If the key is GCP_KEY_JSON and a file path is provided, read the file.
  # Otherwise, look up the value in the defaults map.
  secret_string = (
    each.key == "GCP_KEY_JSON" && var.gcp_key_file_path != ""
    ? file(var.gcp_key_file_path)
    : lookup(var.secret_defaults, each.key, "PENDING_MANUAL_UPDATE")
  )

  lifecycle {
    ignore_changes = [secret_string]
  }
}