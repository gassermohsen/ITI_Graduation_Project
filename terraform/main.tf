module "main" {
    source = "./vpc"
    vpc_cidr="10.0.0.0/16"
    vpc_name="vpc"
}
#internet_gateway
module "gateway"{
    source = "./internet_gateway"
    vpc_id = module.main.vpc-id
    internet_gateway_name = "my_gateway"
}

#subnets
module "subnet"{
    source = "./subnets"
    vpc_id     = module.main.vpc-id
    cidr_subnet = {
    "public1" = "10.0.0.0/24"
    "private1" = "10.0.1.0/24"
    "public2" = "10.0.2.0/24"
    "private2" = "10.0.3.0/24"
}
    aZ = {
    "public1"="us-east-1a"
    "private1"="us-east-1a"
    "public2"="us-east-1b"
    "private2"="us-east-1b"
    }
    egress_cidr = "0.0.0.0/0"
    ingress_cider = "0.0.0.0/0"
    int_gateway = module.gateway.internet_gw_id
    nat_gateway = module.nat.nat_gw_id
    public_keys=["public1","public2"]
    private_keys=["private1","private2"]
}



#nat
module "nat" {
    source = "./nat"
    nat_subnet_id= module.subnet.subnet_id[2]
    nat_name = "nat"
    nat_depends_on = module.gateway
}

module "securityGroup" {
  source               = "./securitygroup"
  vpcid                = module.main.vpc-id
  pup-cidr             = "0.0.0.0/0"
  sg_name              = "security_group"
  sg_description       = "security_group"
  sg_from_port_ingress = 80
  sg_to_port_ingress   = 80
  sg_protocol_ingress  = "tcp"
  sg_from_port_egress  = 0
  sg_to_port_egress    = 0
  sg_protocol_egress   = "-1"
}

module "pub_instance"{
    source = "./ec2public"
    ami = "ami-00874d747dde814fa"
    instance_type = "t2.micro"
    key_name = "ansible"
    subnet_id = module.subnet.subnet_id[2]
    sec_group = module.securityGroup.sg_id
    name = "public-instance"
   

}
module "EKS"{
    source = "./EKS"
    name = "Final-cluster"
    subnet_id = [module.subnet.subnet_id[0],module.subnet.subnet_id[1]]

}

module "EKS-NODE"{
    source = "./eks-node"
    subnet_ids = [module.subnet.subnet_id[0],module.subnet.subnet_id[1]]
    cluster-name = module.EKS.cluster-name


}
