TITLE (paste into Medium title field):
Terraform for AWS — Beginner to Expert: What I Learned Going Deeper

SUBTITLE (paste into Medium subtitle field):
My 30-Day Terraform Challenge was not enough. I went deeper with a full Terraform for AWS course — data types, dynamic blocks, modules, IAM, RDS, and two real challenges. Here is everything I learned.

---

BODY (paste everything below into Medium):

---

The 30-Day Terraform Challenge taught me how to build production-grade infrastructure.

But I wanted to go deeper.

So alongside the challenge, I worked through the Terraform for AWS — Beginner to Expert course. Not to repeat what I already knew. To fill the gaps. To understand the language itself — not just the patterns.

This post covers everything I learned. The data types. The language features. The two challenges I built. And how it all connects to exam preparation.


Why I Did This Alongside the Challenge

The 30-Day Challenge is hands-on. You build things. You hit errors. You fix them.

But it moves fast. Some concepts — data types, tuples, objects, dynamic blocks — get used without being fully explained. I wanted to understand the language at a deeper level before sitting the Terraform Associate exam.

This course gave me that foundation.


1. The Terraform Language — Data Types

The first thing that clicked was that Terraform has a proper type system. It is not just configuration files — it is a typed language.

Strings

variable "environment" {
  type    = string
  default = "dev"
}

Numbers

variable "instance_count" {
  type    = number
  default = 2
}

Booleans

variable "enable_monitoring" {
  type    = bool
  default = false
}

Lists — ordered collection of the same type

variable "ingress_ports" {
  type    = list(number)
  default = [80, 443]
}

Maps — key-value pairs of the same type

variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

Tuples — ordered collection of mixed types

variable "server_config" {
  type    = tuple([string, number, bool])
  default = ["t3.micro", 2, true]
}

Objects — named attributes with specific types

variable "server" {
  type = object({
    instance_type = string
    count         = number
    monitoring    = bool
  })
}

The difference between a map and an object: a map has values all of the same type. An object has named attributes that can be different types. This distinction comes up in the exam.


2. Variables — Five Ways to Pass Values

The course covered every way to pass variable values:

1. Default value in the variable block
2. terraform.tfvars file
3. -var flag on the command line
4. TF_VAR_ environment variable
5. Interactive prompt when no value is provided

The exam tests the precedence order. Command line -var overrides everything. Environment variables override tfvars. tfvars overrides defaults.


3. Outputs

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

Outputs expose values after apply. They are how modules pass data to their callers. Without outputs, a module is a black box — you cannot get any information out of it.


4. Dynamic Blocks — The Feature Most People Skip

This was the most valuable thing I learned in the course.

Dynamic blocks let you generate repeated nested blocks from a variable. Instead of hardcoding ingress rules:

# Without dynamic blocks — repetitive
resource "aws_security_group" "web" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

You write it once with a dynamic block:

# With dynamic blocks — DRY
variable "ingress_ports" {
  type    = list(number)
  default = [80, 443]
}

resource "aws_security_group" "web" {
  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

Add a port to the list — the security group rule is created automatically. Remove a port — the rule is removed. No code changes needed.

I used this in Challenge 2 for both ingress and egress rules.


5. Challenge 1 — Deploy a VPC

The first challenge: create an AWS VPC using Terraform from scratch.

provider "aws" {
  region = "eu-north-1"
}

resource "aws_vpc" "TerraformVPC" {
  cidr_block = "192.168.0.0/24"

  tags = {
    Name = "TerraformVPC"
  }
}

Simple. But the point was not the VPC — it was the workflow. terraform init, terraform plan, terraform apply, verify in the console, terraform destroy. The core loop that everything else builds on.

📸 Screenshot here — VPC created in AWS console
Caption: Challenge 1 — TerraformVPC created with CIDR 192.168.0.0/24


6. Challenge 2 — EC2 with Security Groups, EIP, and Dynamic Blocks

The second challenge was more complex: deploy a web server and a database server, with an Elastic IP on the web server and a security group using dynamic blocks.

provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "WebServer" {
  ami             = "ami-0c94855ba95c71c99"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.WebServerSG.id]
  user_data       = file("server-script.sh")

  tags = { Name = "Web Server" }
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

output "WebServerPublicIP" {
  value       = aws_eip.WebServerIp.public_ip
  description = "Public IP address of the Web Server"
}

Three things this challenge taught me:

1. file() function — reads a shell script and passes it as user_data. The server bootstraps itself on first boot.

2. Elastic IP — a static public IP that stays the same even if the instance is stopped and restarted. Without it, the public IP changes every time.

3. Dynamic blocks for security groups — add a port to the list, the rule is created. This is the pattern I carried into the 30-Day Challenge for every security group.


The Error I Hit

When I first wrote the security group reference I got this:

Error: Incorrect attribute value type
  on main.tf line 21, in resource "aws_instance" "WebServer":
  21:     security_groups = aws_security_group.WebServerSG

Inappropriate value for attribute "security_groups": set of string required.

I was passing the entire security group object to security_groups. Terraform expected a list of strings — specifically a list of security group IDs.

Wrong:

security_groups = aws_security_group.WebServerSG

Correct:

security_groups = [aws_security_group.WebServerSG.id]

The .id attribute extracts just the ID string from the resource object. The square brackets wrap it in a list. This is a common mistake — referencing the whole resource when you only need one attribute.


7. What Else the Course Covered

Modules — the same pattern I used throughout the 30-Day Challenge. Reusable code, inputs, outputs, separation of concerns.

IAM — creating users, policies, and attaching them. The principle of least privilege. This is critical for the exam.

RDS — creating a database instance in Terraform. The connection between the application and the database through security groups and outputs.

Remote backend — S3 + DynamoDB for state storage and locking. I set this up on Day 6 of the challenge and used it for every day after.

Data sources — reading existing infrastructure without creating it. The difference between a data source and a resource.

terraform import — bringing existing infrastructure under Terraform management. I practised this on Day 19.

Count — creating multiple copies of a resource. The deprecation warning about count with lists and why for_each is safer.


8. How This Connects to the Exam

The Terraform Associate exam tests the language at a precise level. Not just "what does terraform apply do" but "what is the difference between a tuple and an object?" and "when would you use a dynamic block?"

The course filled those gaps. After completing it alongside the 30-Day Challenge, I scored 121/200 on a knowledge assessment — Established range, better than 66% of assessed learners.

The combination of hands-on building (challenge) and language depth (course) is what gets you there.


Key Lessons Learned

- Terraform has a proper type system — strings, numbers, booleans, lists, maps, tuples, objects
- The difference between a map and an object: map has same-type values, object has named attributes of different types
- Dynamic blocks eliminate repetitive nested blocks — add to the list, the resource updates automatically
- file() reads a local file and returns its contents — useful for user_data scripts
- Elastic IP gives a static public IP that survives instance restarts
- Variable precedence: -var flag > environment variable > tfvars > default
- Remote backend with S3 + DynamoDB is the foundation everything else builds on


The Code

All challenge code is in my GitHub repository:
[Terraform Challenges](https://github.com/SarahWanjiru/Terraform-challenges)

The full 30-Day Challenge code is here:
[30 Days of Terraform Challenge](https://github.com/SarahWanjiru/30daysof-TerraformChallenge)


One question before you go:

Which Terraform data type confused you the most when you first started — tuples, objects, or the difference between list and set?

Drop it in the comments. I am building a list of the concepts that trip people up most.

If this post helped you, clap so more engineers find it before their exam.

Follow me here on Medium — the challenge posts keep coming.

I am currently doing the 30-Day Terraform Challenge while building Cloud and DevOps skills in public. Open to opportunities — using this time to build real-world skills by actually doing and breaking things.

I am Sarah Wanjiru — a frontend developer turned cloud and DevOps engineer, sharing every step of the transition in public. The mistakes. The fixes. The moments things finally click. Follow along if that sounds useful. 🤝💫

#30DayTerraformChallenge #TerraformChallenge #Terraform #TerraformAssociate #AWS #IaC #DevOps #AWSUserGroupKenya #EveOps #WomenInTech #BuildInPublic #CloudComputing #Andela
DevOps
Terraform
AWS
Infrastructure As Code
Buildinginpublic
