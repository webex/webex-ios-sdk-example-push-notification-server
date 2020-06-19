# Overview

[Cisco Webex iOS SDK](https://developer.webex.com/docs/sdks/ios) enables you to embed [Cisco Webex](https://www.webex.com/) calling and meeting experience into your iOS mobile application. The SDK provides APIs to make and receive audio/video calls. In order to receive audio/video calls, the user needs to be notified when someone is calling the user.

This sample Webhook/Push Notification Server demonstrates how to write a server application to receive [Incoming Call Notification](https://developer.webex.com/docs/sdks/ios) from Cisco Webex and use [Apple Push Notification Service](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html#//apple_ref/doc/uid/TP40008194-CH8-SW1) to notify the mobile application.

This sample is built upon [apns4j](https://github.com/teaey/apns4j) and [Sprint Boot](https://projects.spring.io/spring-boot). It is designed to be deployed and run on [Heroku](https://www.heroku.com). But it can be deployed and run on other environments with minimal changes.

For more information about iOS remote notification, please see [Apple developer guide](https://developer.apple.com/notifications/).

# How it works

Assuming this sample Webook/Push Notification Server has been deployed on the public Internet, the following describes the webhooks and push notification workflow step by step.

![Webex-IOSSDK-APNS](https://dsc.cloud/hello/Spark-IOSSDK-APNS-1509615302.png)

1. Register to the Apple Push Notification Service (APNs) when your iOS application is launching.

2. The APNs returns a device token to the application.

3. Register the device token returned by the APNs and the user Id of current user to the  Webhook/Push Notification Server. The Server stores these information locally in a database.
	```
	let paramaters: Parameters = [
		"email": email,
		"voipToken": voipToken,
		"msgToken": msgToken,
		"personId": personId
	]
	Alamofire.request("https://example.com/register", method: .post, parameters: paramaters, encoding: JSONEncoding.default).validate().response { res in
		// ...
	}
	```

4. After the user logs into Cisco Webex，use [Webhook API](https://webex.github.io/webex-ios-sdk/Classes/WebhookClient.html) to create an webhook at Cisco Webex cloud. The target URL of the webhook must be the /webhook REST endpoint of this server. The URL has to be publicly accessible from the Internet.
	```
	webex.webhooks.create(name: "Incoming Call Webhook", targetUrl: targetUrl, resource: "callMemberships", event: "created", filter: "state=notified&personId=me") { res in
		switch res.result {
	        case .success(let webhook):
            	// perform positive action
	        case .failure(let error):
            	// perform negative action
	    	}
	}
	```

5. The remote party makes a call via Cisco Webex.

6. Ciso Webex receives the call and triggers the webhook. The incoming call event is sent to the target URL, which should be /webhook REST endpoint of this Webhook/Push Notification server.

7. The Webhook/Push Notification Server looks up the device token from the database by the user Id in the incoming call event, then sends the notification with the device token and incoming call information to the APNs.

8. The APNs pushs notification to the iOS device.

9. Your iOS application [gets the push notification](https://github.com/webex/webex-ios-sdk-example-buddies/tree/master/Buddies/AppDelegate.swift#L170) and uses the SDK API to accept the call from Spark Cloud.

For more details about Step 1 and 2, please see [Apple Push Notifications Guide]((https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/index.html#//apple_ref/doc/uid/TP40008194-CH3-SW1))

For more details about Step 3 and 6, please see Cisco Webex [Webhooks Guide](https://developer.webex.com/docs/api/guides/webhooks)

# Deployment

The sample application can be easily deployed as a [Java application on the Heroku](https://devcenter.heroku.com/categories/java).

1. Create an Herko account and [set up](https://devcenter.heroku.com/articles/getting-started-with-java#set-up) the Heroku environment.

2. Create a new Heroku app.

3. Clone the [sample code](https://sqbu-github.cisco.com/SDK4Spark/webex-ios-sdk-example-push-notification-server/) to a local directory.
	```
	git clone git@sqbu-github.cisco.com:SDK4Spark/webex-ios-sdk-example-push-notification-server.git
	```

4. Copy your Apple Push Certificates to `./webex-ios-sdk-example-push-notification-server/.jdk-overlay/jre/lib/security`.

	Sending and receiving push notifications requires you to create Apple Push Certificates. For this sample application, you should create and upload three certificates corresponding, one for each type: Development, Production and VoIP Services.
	
	Apple Push Certificates are generated from the [Apple Developer Member Center](https://developer.apple.com/account/overview.action) which requires a valid Apple ID to login. 
	
5. Deploy the application to Heroku.
	```
	heroku git:remote -a YOUR_APP_NAME
	git add .
	git commit -am "First Deploy"
	git push heroku master
	```

# REST API endpoints and Usage

The sample Webhook/Push Notification server provides three REST API endpoints.

* `POST /webhook` -- This REST API endpoint should be used as the target URL for Cisco Webex [Webhooks Guide](https://developer.webex.com/docs/api/guides/webhooks). Cisco Webex post the incoming call event to this endpoint.

	Please see [the implementation](https://github.com/webex/webex-ios-sdk-example-push-notification-server/blob/master/src/main/java/com/ciscowebex/iossdk/example/pns/Main.java#L117) for more details.

* `POST /register` -- This REST API endpoint should be used by the moible application to register the device token and user id to this sample server.

	Please see [the implementation](https://github.com/webex/webex-ios-sdk-example-push-notification-server/blob/master/src/main/java/com/ciscowebex/iossdk/example/pns/Main.java#L163) for more details.
	
* `DELETE /register/{device_token}` -- This REST API endpoint should be used to delete the registered device token.

	Please see [the implementation](https://github.com/webex/webex-ios-sdk-example-push-notification-server/blob/master/src/main/java/com/ciscowebex/iossdk/example/pns/Main.java#L182) for more details.
