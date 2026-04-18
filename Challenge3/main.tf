provider "aws" {
    region = "eu-north-1"
}

module "sg" {
    source = "./sg"
}

module "db" {
    source = "./db"
}

module "web" {
    source = "./web"
    sg_id  = module.sg.WebServerSGId
}

module "eip" {
    source      = "./eip"
    instance_id = module.web.instance_id
}

# --- Root Outputs ---

output "DbServerPrivateIp" {
    value       = module.db.DbServerPrivateIp
    description = "Private IP address of the DB Server"
}

output "PublicIP" {
    value       = module.eip.WebServerPublicIP
    description = "Public IP address of the Web Server"
}