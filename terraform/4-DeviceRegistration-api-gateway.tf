resource "aws_apigatewayv2_integration" "lambda_DeviceRegistration" {
  api_id = aws_apigatewayv2_api.main.id

  integration_uri    = aws_lambda_function.DeviceRegistration.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# Handle the POST route /deviceRegistration
resource "aws_apigatewayv2_route" "post_DeviceRegistration" {
  api_id = aws_apigatewayv2_api.main.id

  route_key = "POST /deviceRegistration"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_DeviceRegistration.id}"
}

# Handle the DELETE route /deviceRegistration
resource "aws_apigatewayv2_route" "delete_DeviceRegistration" {
  api_id = aws_apigatewayv2_api.main.id

  route_key = "DELETE /deviceRegistration/{userId}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_DeviceRegistration.id}"
}

resource "aws_lambda_permission" "api_gw_DeviceRegistration" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.DeviceRegistration.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}


output "DeviceRegistration_base_url" {
  value = aws_apigatewayv2_stage.prod.invoke_url
}
