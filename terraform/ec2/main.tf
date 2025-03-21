# Security Group

resource "aws_security_group" "this" {

    name = "cpt-humanitec-poc-sg"
    description = "Test Security Group for Humanitec POC"
    vpc_id      = var.vpc_id

    tags = {
        Name = "cpt-humanitec-poc-sg"
    }
  
}


module "ec2" {
  source    = "terraform-aws-modules/ec2/aws"

  name = "cpt-humanitec-poc"

  subnet_id              = element(var.subnets, 0)
  vpc_security_group_ids = [aws_security_group.this.id]

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}