variable "instance_id" {
    description = "ID of the EC2 instance to associate with the EIP"
    type        = string
}

resource "aws_eip" "WebServerIp" {
    instance = var.instance_id
    tags = {
        Name = "Web Server IP"
    }
}

output "WebServerPublicIP" {
    value       = aws_eip.WebServerIp.public_ip
    description = "Public IP address of the Web Server"
}