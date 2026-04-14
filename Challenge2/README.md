# Challenge 2 — EC2 Web Server with Security Groups, EIP, and Dynamic Blocks

Deploy a web server and database server on AWS with an Elastic IP, dynamic security group rules, and a bootstrap script.

---

## What You'll Build

- Two EC2 instances — Web Server and DB Server
- Elastic IP attached to the Web Server
- Security group with dynamic ingress and egress rules for ports 80 and 443
- User data script that bootstraps the web server on first boot
- Outputs exposing the public and private IP of the web server

---

## Steps

### 1. terraform init

![terraform init output](screenshots/terraform-init.png)

---

### 2. The Error I Hit

When I first wrote the security group reference I got this error:

```
Error: Incorrect attribute value type

  on main.tf line 21, in resource "aws_instance" "WebServer":
  21:     security_groups = aws_security_group.WebServerSG

Inappropriate value for attribute "security_groups": set of string required.
```

![security_groups error](screenshots/error.png)

**What went wrong:**

I was passing the entire security group object to `security_groups`. Terraform expected a list of strings — specifically a list of security group ID strings.

**Wrong:**
```hcl
security_groups = aws_security_group.WebServerSG
```

**Correct:**
```hcl
security_groups = [aws_security_group.WebServerSG.id]
```

The `.id` attribute extracts just the ID string from the resource object. The square brackets wrap it in a list. This is a common mistake — referencing the whole resource when you only need one attribute.

---

### 3. terraform plan

After fixing the error, the plan showed 4 resources to add:

```
Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + WebServerPrivateIp = (known after apply)
  + WebServerPublicIP  = (known after apply)
```

![terraform plan output](screenshots/terraform-plan.png)

---

## The Code

```hcl
provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "DbServer" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  tags          = { Name = "Db Server" }
}

resource "aws_instance" "WebServer" {
  ami             = "ami-0c94855ba95c71c99"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.WebServerSG.id]
  user_data       = file("server-script.sh")
  tags            = { Name = "Web Server" }
}

resource "aws_eip" "WebServerIp" {
  instance = aws_instance.WebServer.id
  tags     = { Name = "Web Server IP" }
}

variable "ingress" {
  type    = list(number)
  default = [80, 443]
}

variable "egress" {
  type    = list(number)
  default = [80, 443]
}

resource "aws_security_group" "WebServerSG" {
  name        = "WebServerSG"
  description = "Allow HTTP and HTTPS traffic"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingress
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    iterator = port
    for_each = var.egress
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

output "WebServerPrivateIp" {
  value       = aws_eip.WebServerIp.private_ip
  description = "Private IP address of the Web Server"
}

output "WebServerPublicIP" {
  value       = aws_eip.WebServerIp.public_ip
  description = "Public IP address of the Web Server"
}
```

---

## Key Learnings

- `security_groups` expects a list of ID strings — use `[resource.name.id]` not `resource.name`
- Dynamic blocks generate repeated nested blocks from a variable — add a port to the list, the rule is created automatically
- `file()` reads a local file and passes its contents as a string — used here for the user_data bootstrap script
- Elastic IP gives a static public IP that survives instance restarts

---

## Resources Created

| Resource | Name | Notes |
|---|---|---|
| aws_instance | Web Server | With user_data bootstrap script |
| aws_instance | Db Server | Plain instance |
| aws_eip | Web Server IP | Static public IP |
| aws_security_group | WebServerSG | Dynamic rules for ports 80 and 443 |
