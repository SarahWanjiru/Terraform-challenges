#!/bin/bash
dnf update -y
dnf install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello from SarahCanCode! Instance </h1>" |  sudo tee /var/www/html/index.html