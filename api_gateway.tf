resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = local.api_gateway_name
  description = "Gateway centralizador de APIs"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.tags,
    {
      resource = local.api_gateway_name
    }
  )
}

resource "aws_api_gateway_authorizer" "api_gateway_authorizer" {
  rest_api_id                      = aws_api_gateway_rest_api.api_gateway.id
  name                             = "custom_authorizer"
  authorizer_uri                   = local.aws_authorizer_arn
  type                             = "REQUEST"
  identity_source                  = "method.request.header.channel,method.request.header.authorization"
  authorizer_result_ttl_in_seconds = 0
}

resource "aws_api_gateway_stage" "api_gateway_stage" {
  depends_on           = [aws_cloudwatch_log_group.api_gateway]
  deployment_id        = aws_api_gateway_deployment.api_gateway_deployment.id
  rest_api_id          = aws_api_gateway_rest_api.api_gateway.id
  stage_name           = local.env
  xray_tracing_enabled = true

  #cache_cluster_enabled = true
  #cache_cluster_size    = "1.6"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId         = "$context.requestId"
      extendedRequestId = "$context.extendedRequestId"
      requestTime       = "$context.requestTime"
      requestTimeEpoch  = "$context.requestTimeEpoch"
      protocol          = "$context.protocol"
      method            = "$context.httpMethod"
      resourcePath      = "$context.$context.resourcePath"
      path              = "$context.path"
      status            = "$context.status"
      responseLength    = "$context.responseLength"
      sourceIp          = "$context.identity.sourceIp"
      caller            = "$context.identity.caller"
      user              = "$context.identity.user"
    })
  }

  tags = merge(
    local.tags,
    {
      "resource" = "${local.api_gateway_name}-stage-${local.env}"
    }
  )
}

resource "aws_apigatewayv2_api_mapping" "api_gateway_mapping" {
  depends_on = [aws_api_gateway_stage.api_gateway_stage]

  api_id          = aws_api_gateway_rest_api.api_gateway.id
  stage           = aws_api_gateway_stage.api_gateway_stage.stage_name
  domain_name     = local.custom_dns
  api_mapping_key = "api"
}

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  depends_on = [
    module.api_module.api_module_options_method,
    module.api_module.api_module_any_method,
    module.api_module.api_module_options_method_mock,
    module.api_module.api_module_vpc_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  triggers = {
    redeployment = sha1(jsonencode([
      timestamp()
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_method_settings" "api_gateway_all_routes" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.api_gateway_stage.stage_name
  method_path = "*/*"

  settings {
    logging_level      = "INFO"
    metrics_enabled    = true
    data_trace_enabled = false
  }
}
