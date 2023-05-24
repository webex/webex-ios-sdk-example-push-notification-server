# TODO: Fix this file
resource "aws_dynamodb_table" "DeviceRegistrations" {
  name         = "DeviceRegistrations"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "userId"
  range_key = "deviceToken"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "deviceToken"
    type = "S"
  }

  tags = {
    Name = "WebexSDK-Webhook-Handler"
  }
}