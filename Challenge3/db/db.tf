resource "aws_instance" "db_server" {
    ami           = "ami-0aaa636894689fa47"
    instance_type = "t3.micro"

    tags = {
        Name = "DB Server"
    }
}

output "DbServerPrivateIp" {
    value = aws_instance.db_server.private_ip
}