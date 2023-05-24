resource "aws_apigatewayv2_api" "main" {
  name          = "webex-mobile-sdk-webhook-handler"
  protocol_type = "HTTP"

  disable_execute_api_endpoint = false # set to true to disable the use of default host url provided by AWS

  tags = {
    Name = "WebexSDK-Webhook-Handler"
  }
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id = aws_apigatewayv2_api.main.id

  name        = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.main_api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }

  tags = {
    Name = "WebexSDK-Webhook-Handler"
  }
}

resource "aws_cloudwatch_log_group" "main_api_gw" {
  name = "/aws/api-gw/${aws_apigatewayv2_api.main.name}"

  retention_in_days = 7

  tags = {
    Name = "WebexSDK-Webhook-Handler"
  }
}
