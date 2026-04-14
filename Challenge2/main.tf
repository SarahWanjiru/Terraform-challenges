provider "aws" {
    region = "eu-north-1"
}

variable "ingress" {
    type = list(number)
    default = [80,443]
}

variable "egress" {
    type = list(number)
    default = [80,443]
}

resource "aws_security_group" "WebServerSG" {
    name = "WebServerSG"
    description = "Allow HTTP and HTTPS traffic"

    dynamic "ingress" {
        iterator = port
        for_each = var.ingress
        content {
            from_port = port.value
            to_port = port.value
            protocol = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    dynamic "egress" {
        iterator = port
        for_each = var.egress
        content {
            from_port = port.value
            to_port = port.value
            protocol = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}

resource "aws_instance" "DbServer" {
    ami = "ami-0aaa636894689fa47"
    instance_type = "t3.micro"

    tags = {
        Name = "Db Server"
    }
}

resource "aws_instance" "WebServer" {
    ami = "ami-0aaa636894689fa47"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.WebServerSG.id]
    user_data = file("server-script.sh")

    tags = {
        Name = "Web Server"
    }
}

resource "aws_eip" "WebServerIp" {
    instance = aws_instance.WebServer.id
    tags = {
        Name = "Web Server IP"
    }
}

output "WebServerPrivateIp" {
    value = aws_eip.WebServerIp.private_ip
    description = "Private IP address of the Web Server"
}

output "WebServerPublicIP" {
    value = aws_eip.WebServerIp.public_ip
    description = "Public IP address of the Web Server"
}