# Challenge 1 — Deploy a VPC with Terraform

Create an AWS VPC using Terraform from scratch.

## What You'll Build

- A VPC with CIDR block `192.168.0.0/24` in `eu-north-1`

## Prerequisites

- Terraform installed (`>= 1.0.0`)
- AWS CLI configured with valid credentials



## Steps

### 1. Create `main.tf`

```hcl
provider "aws" {
  region = "eu-north-1"
}

resource "aws_vpc" "TerraformVPC" {
  cidr_block = "192.168.0.0/24"

  tags = {
    Name = "TerraformVPC"
  }
}
```



### 2. Initialize Terraform

```bash
terraform init
```

![alt text](<Screenshot from 2026-04-07 20-40-27.png>)


### 3. Preview the Plan

```bash
terraform plan
```


![terrafrom plan output](<Screenshot from 2026-04-07 20-40-09.png>)


### 4. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted.
![propmt enter yes](image.png)



### 5. Verify in AWS Console

Navigate to **VPC → Your VPCs** and confirm `TerraformVPC` is listed.

![VPC cretaed in console](<Screenshot from 2026-04-07 20-39-43.png>)


### 6. Destroy the Resources

```bash
terraform destroy
```

Type `yes` when prompted.

![terraform destroy output](<Screenshot from 2026-04-07 20-41-11.png>)



## Resources Created

| Resource | Name | CIDR |
|---|---|---|
| AWS VPC | TerraformVPC | 192.168.0.0/24 |
