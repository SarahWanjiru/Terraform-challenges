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

output "WebServerSGId" {
    value = aws_security_group.WebServerSG.id
}

output "sg_name" {
    value = aws_security_group.WebServerSG.name
}