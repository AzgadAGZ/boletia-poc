data "aws_subnet" "private_subnets" {
    vpc_id = local.vpc_id

    filter {
        name   = "tag:Name"
        values = ["*private*"]
    }
}