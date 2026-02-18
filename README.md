# 🔐 Setup Secure Backend

Before provisioning the infrastructure, configure **remote state management** using **Amazon S3** (for storing state) and **DynamoDB** (for state locking and consistency).

This setup ensures:
- 👥 **Team collaboration** with shared state  
- 🚫 **Prevention of concurrent** `terraform apply`  
- 🗂️ **Version-controlled and recoverable** infrastructure state  

---

## 1️⃣ Create the S3 Bucket

Use the AWS CLI or Console to create the S3 bucket that will hold your Terraform state:

```bash
aws s3api create-bucket   --bucket my-ecs-terraform-state   --region us-east-1
```

Enable **versioning** for safety:

```bash
aws s3api put-bucket-versioning   --bucket my-ecs-terraform-state   --versioning-configuration Status=Enabled
```

---

## 2️⃣ Create the DynamoDB Table for Locking

Create a **DynamoDB table** to manage state locks and avoid race conditions:

```bash
aws dynamodb create-table   --table-name terraform-locks   --attribute-definitions AttributeName=LockID,AttributeType=S   --key-schema AttributeName=LockID,KeyType=HASH   --billing-mode PAY_PER_REQUEST
```

---

✅ Once the backend resources are ready, reference them in your Terraform configuration to enable secure, shared remote state.

Example backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-ecs-terraform-state"
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

---

**Next Steps:**
- Initialize the backend with `terraform init`
- Apply your infrastructure changes with `terraform apply`

---

> 💡 **Tip:** Always enable versioning on the S3 bucket to recover from accidental deletions or corrupt state files.

---

## 🌐 Custom Domain & HTTPS Setup

The ALB is configured with an ACM certificate for HTTPS. This section covers how to map a custom subdomain (e.g., `mobile.ambulensi.org`) to the ALB with SSL/TLS.

### How It Works

- Terraform creates an **ACM certificate** with DNS validation
- An **HTTPS listener** (port 443) serves traffic with the certificate
- The **HTTP listener** (port 80) redirects all traffic to HTTPS (301)
- The `domain_name` variable controls the certificate domain (default: `mobile.ambulensi.org`)

### Deployment Steps

#### 1. Apply Terraform

```bash
terraform apply
```

The apply will **block** at `aws_acm_certificate_validation` — this is expected. It's waiting for you to add the DNS validation record.

#### 2. Get the ACM Validation Record

In a **separate terminal**, run:

```bash
terraform output acm_validation_records
```

This outputs something like:

```
{
  "mobile.ambulensi.org" = {
    "name"  = "_abc123.mobile.ambulensi.org."
    "type"  = "CNAME"
    "value" = "_def456.jkddzztszm.acm-validations.aws."
  }
}
```

#### 3. Add Validation CNAME on Your DNS Provider

On your DNS provider (e.g., Siteground), add a CNAME record:

| Field | Value |
|-------|-------|
| **Name** | `_abc123.mobile` (drop `.ambulensi.org.` — the provider appends the zone automatically) |
| **Type** | CNAME |
| **Value** | `_def456.jkddzztszm.acm-validations.aws` (drop the trailing dot) |

> ⚠️ **Important:** Do NOT include trailing dots (`.`) in either the name or value fields. Most DNS providers append the zone automatically.

#### 4. Wait for Validation

Once DNS propagates (1–5 minutes), the ACM validation completes and `terraform apply` finishes. You can verify propagation with:

```bash
dig CNAME _abc123.mobile.ambulensi.org
```

#### 5. Add the Application CNAME

Add a second CNAME to route actual traffic to the ALB:

| Field | Value |
|-------|-------|
| **Name** | `mobile` |
| **Type** | CNAME |
| **Value** | ALB DNS name from `terraform output alb_endpoint` |

#### 6. Verify

- `https://mobile.ambulensi.org` — should serve your application
- `http://mobile.ambulensi.org` — should redirect to HTTPS

### Using a Different Domain

Override the default domain via variable:

```bash
terraform apply -var="domain_name=api.example.com"
```

Or set it in `terraform.tfvars`:

```hcl
domain_name = "api.example.com"
```
