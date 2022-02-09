locals {
  s3_origin_arn = join("", ["arn:aws:s3:::", var.bucketname, "/*"])
  oai-full-name = join("", ["arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ", var.oaiid])
}


data "aws_s3_bucket" "s3-bucket" {
  bucket = var.bucketname
}


data "aws_iam_policy_document" "oai-config-policy-document" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [local.oai-full-name]
    }
    actions   = ["s3:GetObject"]
    resources = [local.s3_origin_arn]
  }
}


resource "aws_s3_bucket_policy" "oai-config-policy" {
  bucket = data.aws_s3_bucket.s3-bucket.id
  policy = data.aws_iam_policy_document.oai-config-policy-document.json
}
