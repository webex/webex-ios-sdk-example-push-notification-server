const aws = require("aws-sdk");
const apn = require("apn");
aws.config.update({ region: "us-east-1" });
var docClient = new aws.DynamoDB.DocumentClient({ apiVersion: "2012-08-10" });
var pinpoint = new aws.Pinpoint();

const constants = {
  TABLE_NAME: process.env.DEVICE_TOKENS_TABLE_NAME,
  APPLE_BUNDLE_IDENTIFIER: process.env.APPLE_BUNDLE_IDENTIFIER,
  PINPOINT_APPLICATION_ID: process.env.PINPOINT_APPLICATION_ID,
};

const invokePinpointSendMessage = async (
  apnsMessage,
  fcmMessage,
  addresses
) => {
  try {
    let result = await pinpoint
      .sendMessages({
        ApplicationId: constants.PINPOINT_APPLICATION_ID,
        MessageRequest: {
          MessageConfiguration: {
            APNSMessage: apnsMessage,
            GCMMessage: fcmMessage,
          },
          Addresses: addresses,
        },
      })
      .promise();

    console.log(JSON.stringify(result, null, 2));
  } catch (error) {
    console.error(error);
  }
};

const getTokenForUserId = async (userId) => {
  const queryParams = {
    TableName: constants.TABLE_NAME,
    KeyConditionExpression: "userId = :id",
    ExpressionAttributeValues: {
      ":id": userId,
    },
  };
  return docClient.query(queryParams).promise();
};

const handleWebhookPayload = async (payload, tokens) => {
  var addresses = {};
  var apnsMessage = {};
  var fcmMessage = {};

  const startTime = (new Date()).getTime();
  if ("resource" in payload && payload["resource"] == "telephony_push") {
    // pass only the respective payloads from bsft
    var rawAPNSBody = JSON.stringify({
      ...payload.data.apnsPayload,
      aps: {},
      "content-available": 1,
      "source" : "webhook"
    });
    var rawFCMBody = JSON.stringify(payload.data.fcmPayload);

    apnsMessage = {
      APNSPushType: "voip",
      TimeToLive: 60,
      RawContent: rawAPNSBody,
    };

    fcmMessage = {
      Data: { webhookTelephonyPush : rawFCMBody},
      SilentPush: true,
      TimeToLive: 60,
      Priority: "high",
    };

    addresses = tokens
    .map((item) => {
        let ret = {}
        if(item.pushProvider == "APNS"){
            let pushType = "APNS_VOIP_SANDBOX";
            if(item.prod) {
                pushType = "APNS_VOIP";
            }
             ret[item.voipToken] = { ChannelType : pushType }
        }else {
            ret[item.deviceToken] = { ChannelType : "GCM"}
        }
    
      return ret;
    }).reduce((acc, item) => {
        for (let key in item) acc[key] = item[key];
        return acc;
      }, {});
  } else {
    // Just push the webhook data as it is via Normal APNS / FCM

    var rawAPNSBody = JSON.stringify({
      webhookData: { ...payload },
      aps: {},
      Priority: "5",
      "content-available": 1,
    });

    var rawFCMBody = JSON.stringify({ ...payload });

    apnsMessage = {
      APNSPushType: "background",
      TimeToLive: 0,
      RawContent: rawAPNSBody,
      SilentPush: true,
    };

    fcmMessage = {
      RawContent: rawFCMBody,
      TimeToLive: 0,
      Priority: "normal",
    };

    addresses = tokens
    .map((item) => {
        let ret = {}
        if(item.pushProvider == "APNS"){
            let pushType = "APNS_SANDBOX";
            if(item.prod) {
                pushType = "APNS";
            }
             ret[item.deviceToken] = { ChannelType : pushType }
        }else {
            ret[item.deviceToken] = { ChannelType : "GCM"}
        }
    
      return ret;
    }).reduce((acc, item) => {
        for (let key in item) acc[key] = item[key];
        return acc;
      }, {});
  }

  await invokePinpointSendMessage(apnsMessage, fcmMessage, addresses);
  
  console.log("fcmMessage "+ JSON.stringify(fcmMessage))
  console.log("PROFILETIME: "+payload["resource"]+ " "+getUserId(payload)+ " "+((new Date()).getTime()-startTime));

  return;
};

const getUserId = (body) => {
  let userId = body["createdBy"];
  if ("resource" in body) {
    if(body["resource"] == "telephony_push") {
      userId =  body["actorId"]
    }
  }
  return userId;
}

exports.handler = async (event) => {
  console.log("Event: ", event);

  const body = JSON.parse(event.body);
  if (!("createdBy" in body)) {
    console.error("No createdBy found in webhook body. We cannot proceed!");
    const response = {
      statusCode: 400,
    };
    return response;
  }
  const userId = getUserId(body);
  try {
    /// Using the userId, query all deviceIds in the DDB, then loop and call a method for each of the found deviceId
    const result = await getTokenForUserId(userId);
    console.log(`Retreived DeviceToken count: ${result.Count}`);

    await handleWebhookPayload(body, result.Items);
    
    const response = {
      statusCode: 200,
    };

    return response;
  } catch (error) {
    console.error(error);

    const response = {
      statusCode: 400,
    };

    return response;
  }
};
