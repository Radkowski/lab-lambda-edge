# main module

variable "DeploymentRegion" {
  default = "us-east-1"
  type    = string
}

variable "DeploymentName" {
  default = "Lambdaedge"
  type    = string
}


# lambda@edge module


variable "client_id" {
  type    = string
  default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

variable "client_secret" {
  type    = string
  default = "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
}

variable "tenant" {
  type    = string
  default = "zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz"
}

variable "redirect_uri" {
  type    = string
  default = "https://lab-s3-auth.radkowski.cloud/_callback"
}


# cloudfront module

variable "bucketname" {
  type    = string
  default = "lab-radkowski-azure-auth"
}
