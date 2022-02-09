
module "lambda-edge-azure-auth" {
  source  = "nickshine/lambda-edge-azure-auth/aws"
  version = "0.3.3"
  client_id        = var.client_id
  client_secret    = var.client_secret
  tenant           = var.tenant
  redirect_uri     = var.redirect_uri
  function_name    = join("", [var.DeploymentName, "-lambda-edge-azure-auth"])
  lambda_role_name = join("", [var.DeploymentName, "-lambda-edge-role"])
}



module "LAMBDA-VERSION-DETECTOR" {
  source         = "./lambda-version-detector"
  depends_on     = [module.lambda-edge-azure-auth]
  DeploymentName = var.DeploymentName
}


module "CLOUDFRONT" {
  source         = "./cloudfront"
  depends_on     = [module.LAMBDA-VERSION-DETECTOR]
  DeploymentName = var.DeploymentName
  bucketname     = var.bucketname
  lambdaedgeurl  = module.LAMBDA-VERSION-DETECTOR.result_entry
}


module "S3-OAI-POLICY" {
  source     = "./s3-oai-policy"
  depends_on = [module.CLOUDFRONT]
  oaiid      = module.CLOUDFRONT.oaiid
  bucketname = var.bucketname
}
