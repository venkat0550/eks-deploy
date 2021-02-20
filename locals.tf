locals {
  pub_sub_ids = "${join(" ", data.aws_subnet_ids.public.ids)}"
}
