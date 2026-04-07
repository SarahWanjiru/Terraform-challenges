provider "aws" {
    region = "eu-north-1"
}

resource "aws_vpc" "TerraformVPC" {
    cidr_block = "192.168.0.0/24"

    tags = {
        Name = "TerraformVPC"
    }
    
    }