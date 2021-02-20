data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["default*"]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["PVT*"]
  }
}


data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["PUB-SUB*"]
  }
}
