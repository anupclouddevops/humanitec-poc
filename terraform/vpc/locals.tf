locals {
  region = "us-east-1"

  public_subnet_tags = {
    Tier = "Public"
  }

  private_subnet_tags = {
    Tier = "Private"
  }

  ### get the AZs and sort them to ensure the order is always the same
  azs = slice(sort(tolist(data.aws_availability_zones.available.names)), 0, 3)

  tags = {
    // Static Tags
    Product     = "IntelePACS Cloud"
    Application = "humanitec-poc"
    Billing     = "humanitec-poc-cost"
    Owner       = "Cloud Platform Team"
    Project     = "Humanitec Exploration"
    CodeManaged = true
    Compliance  = "phi"
    Cluster     = "HUMANITEC"
  }

}