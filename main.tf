provider "aws" {
  region = "us-east-1"
}

module "api_module" {
  source = "./api_module"

  global_config = local.global_config
  data          = local.data
  tags          = local.tags
}

locals {
  region             = var.aws_region
  env                = var.env
  stage              = var.stage
  arn_hash           = var.arn_hash
  api_gateway_name   = var.api_gateway_name
  custom_dns         = var.custom_dns
  aws_authorizer_arn = "arn:aws:lambda:${local.region}:${local.arn_hash}:function:custom-authorizer"

  data = {
    "vpc" : {
      "ecs_security_group_id" : aws_security_group.ecs_security_group.id
      #"lnb_security_group_id" : aws_security_group.nlb_security_group.id
    }
    "api_gateway" : {
      "id" : aws_api_gateway_rest_api.api_gateway.id
      "root_resource_id" : aws_api_gateway_rest_api.api_gateway.root_resource_id
      "authorizer_id" : aws_api_gateway_authorizer.api_gateway_authorizer.id
    }
    "kms" : {
      "key_id" : aws_kms_key.kms_key_cloudwatch.key_id
    }
  }

  tags = {
    "name" : "Infraestrutura AWS",
    "env" : local.env,
    "project" : "Devops",
    "repository" : "aws-with-terraform",
    "owner" : "Marcos Martins",
  }
}
