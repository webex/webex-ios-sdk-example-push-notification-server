resource "aws_iam_role" "HandleWebhook_lambda_exec" {
  name = "HandleWebhook_lambda"

  assume_role_policy = jsonencode({
   "Version" : "2012-10-17",
   "Statement" : [
     {
       "Effect" : "Allow",
       "Principal" : {
         "Service" : "lambda.amazonaws.com"
       },
       "Action" : "sts:AssumeRole"
     }
   ]
  })

  tags = {
    Name = "WebexSDK-Webhook-Handler"
  }

}

resource "aws_iam_role_policy_attachment" "HandleWebhook_lambda_policy" {
  role = aws_iam_role.HandleWebhook_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "HandleWebhook_lambda_dynamodb_policy" {
  name = "HandleWebhook_lambda_dynamodb_policy"
  role = aws_iam_role.HandleWebhook_lambda_exec.id
   policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
           "Effect" : "Allow",
           "Action" : ["dynamodb:*"],
           "Resource" : "${aws_dynamodb_table.DeviceRegistrations.arn}"
        },
        {
           "Effect" : "Allow",
           "Action" : ["mobiletargeting:SendMessages"],
           "Resource" : "${aws_pinpoint_app.KitchenSink_WebexSDK_PushNotifications.arn}/messages"
        }
      ]
   })
}

# Load the lambda source to a bucket
resource "aws_lambda_function" "HandleWebhook" {
  function_name = "HandleWebhook"
  
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key = aws_s3_object.lambda_handle_webhook.key
  
  runtime = "nodejs16.x"
  handler = "function.handler"

  source_code_hash = data.archive_file.lambda_handle_webhook.output_base64sha256

  role = aws_iam_role.HandleWebhook_lambda_exec.arn

  environment {
    variables = {
      "DEVICE_TOKENS_TABLE_NAME": aws_dynamodb_table.DeviceRegistrations.name
      "PINPOINT_APPLICATION_ID": aws_pinpoint_app.KitchenSink_WebexSDK_PushNotifications.application_id,
      "APPLE_BUNDLE_IDENTIFIER": var.apns_bundle_id
    }
  }
  tags = {
    Name = "WebexSDK-Webhook-Handler"
  }
}

resource "aws_cloudwatch_log_group" "HandleWebhook" {
  name = "/aws/lambda/${aws_lambda_function.HandleWebhook.function_name}"

  retention_in_days = 7

  tags = {
    Name = "WebexSDK-Webhook-Handler"
  }
}

data "archive_file" "lambda_handle_webhook" {
  type = "zip"

  source_dir  = "../${path.module}/HandleWebhook"
  output_path = "../${path.module}/HandleWebhook.zip"
}

resource "aws_s3_object" "lambda_handle_webhook" {
  bucket = aws_s3_bucket.lambda_bucket.id
  
  key    = "HandleWebhook.zip"
  source = data.archive_file.lambda_handle_webhook.output_path

  source_hash = filemd5(data.archive_file.lambda_handle_webhook.output_path)

  tags = {
    Name = "WebexSDK-Webhook-Handler"
  }

}