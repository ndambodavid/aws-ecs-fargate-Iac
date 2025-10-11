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
