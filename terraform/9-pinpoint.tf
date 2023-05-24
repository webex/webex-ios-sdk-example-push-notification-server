resource "aws_pinpoint_app" "KitchenSink_WebexSDK_PushNotifications" {
  name = "KitchenSink_WebexSDK_PushNotifications"
}

resource "aws_pinpoint_apns_sandbox_channel" "KitchenSink_WebexSDK_PushNotifications_apns_sandbox_channel" {
  application_id = aws_pinpoint_app.KitchenSink_WebexSDK_PushNotifications.application_id

  bundle_id    = var.apns_bundle_id
  team_id      = var.apns_team_id
  token_key    = var.apns_token_key
  token_key_id = var.apns_token_key_id 
}


resource "aws_pinpoint_apns_voip_sandbox_channel" "KitchenSink_WebexSDK_PushNotifications_apns_voip_sandbox_channel" {
  application_id = aws_pinpoint_app.KitchenSink_WebexSDK_PushNotifications.application_id

  bundle_id    = var.apns_bundle_id
  team_id      = var.apns_team_id
  token_key    = var.apns_token_key
  token_key_id = var.apns_token_key_id 
}

resource "aws_pinpoint_gcm_channel" "KitchenSink_WebexSDK_PushNotifications_gcm_channel" {
  application_id = aws_pinpoint_app.KitchenSink_WebexSDK_PushNotifications.application_id
  api_key = var.fcm_api_key
}