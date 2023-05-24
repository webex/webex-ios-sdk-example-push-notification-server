resource "aws_iam_role" "device_registration_lambda_exec" {
  name               = "DeviceRegistration-lambda"
  assume_role_policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  }
  )
  tags = {
    Name = "WebexSDK-Webhook-Handler"
  }
}

resource "aws_iam_role_policy_attachment" "DeviceRegistration_lambda_policy" {
  role       = aws_iam_role.device_registration_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Allow access to dynamoDB
resource "aws_iam_role_policy" "DeviceRegistration_lambda_dynamodb_policy" {
  name = "DeviceRegistration_lambda_dynamodb_policy"
  role = aws_iam_role.device_registration_lambda_exec.id
   policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
           "Effect" : "Allow",
           "Action" : ["dynamodb:PutItem"],
           "Resource" : "${aws_dynamodb_table.DeviceRegistrations.arn}"
        }
      ]
   })
}

resource "aws_lambda_function" "DeviceRegistration" {
  function_name = "DeviceRegistration"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_device_registration.key

  runtime = "nodejs16.x"
  handler = "function.handler"

  source_code_hash = data.archive_file.lambda_device_registration.output_base64sha256
  role             = aws_iam_role.device_registration_lambda_exec.arn

  environment {
    variables = {
      "DEVICE_TOKENS_TABLE_NAME": aws_dynamodb_table.DeviceRegistrations.name
    }
  }

  tags = {
    Name = "WebexSDK-Webhook-Handler"
  }
}

resource "aws_cloudwatch_log_group" "DeviceRegistration" {
  name              = "/aws/lambda/${aws_lambda_function.DeviceRegistration.function_name}"
  retention_in_days = 7
  tags = {
    Name = "WebexSDK-Webhook-Handler"
  }
}

data "archive_file" "lambda_device_registration" {
  type = "zip"

  source_dir  = "../${path.module}/DeviceRegistration"
  output_path = "../${path.module}/DeviceRegistration.zip"
}

resource "aws_s3_object" "lambda_device_registration" {
  bucket = aws_s3_bucket.lambda_bucket.id
  
  key    = "DeviceRegistration.zip"
  source = data.archive_file.lambda_device_registration.output_path

  source_hash = filemd5(data.archive_file.lambda_device_registration.output_path)

tags = {
    Name = "WebexSDK-Webhook-Handler"
  }
}
