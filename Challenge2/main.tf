provider "aws" {
    region = "eu-north-1"
}

resource "aws_instance" "Challenge2Instance" {
    ami = "ami-0bfa6d0ea0fe2c5a1"
    instance_type = "t3.micro"

    tags = {
        Name = "Challenge2Instance"
    }
}

resource "aws_security_group" "challenge2sg" {
    ingress {
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }

        egress =  {
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
} 
  
