resource "aws_apigatewayv2_integration" "lambda_HandleWebhook" {
  api_id = aws_apigatewayv2_api.main.id

  integration_uri    = aws_lambda_function.HandleWebhook.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# Handle the POST route /handleWebhook
resource "aws_apigatewayv2_route" "post_HandleWebhook" {
  api_id = aws_apigatewayv2_api.main.id

  route_key = "POST /handleWebhook"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_HandleWebhook.id}"
}

resource "aws_lambda_permission" "api_gw_handleWebhook" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.HandleWebhook.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}


output "HandleWebhook_base_url" {
  value = aws_apigatewayv2_stage.prod.invoke_url
}
