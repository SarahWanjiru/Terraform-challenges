variable "sg_id" {
    type = string
}

resource "aws_instance" "WebServer" {
    ami                    = "ami-0aaa636894689fa47"
    instance_type          = "t3.micro"
    vpc_security_group_ids = [var.sg_id]
    user_data              = file("${path.module}/server-script.sh")

    tags = {
        Name = "Web Server"
    }
}

output "instance_id" {
    value = aws_instance.WebServer.id
}