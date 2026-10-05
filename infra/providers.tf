provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# CloudFront requires ACM certificates to be issued in us-east-1, regardless
# of which region the rest of the stack lives in.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = local.common_tags
  }
}
