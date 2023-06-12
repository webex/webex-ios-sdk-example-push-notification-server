const aws = require("aws-sdk");
const region = "us-east-1";
var docClient = new aws.DynamoDB.DocumentClient({
  apiVersion: "2012-08-10",
  region: region,
});
const TABLE_NAME = process.env.DEVICE_TOKENS_TABLE_NAME;

const storeTokenForUserId = async (
  userId,
  deviceToken,
  pushProvider,
  voipToken = "",
  prod = false
) => {
  var params = {
    TableName: TABLE_NAME,
    Item: {
      deviceToken: deviceToken,
      userId: userId,
      pushProvider: pushProvider,
      voipToken: voipToken,
      prod : prod,
      updatedAt: new Date().toISOString(),
    },
  };

  return docClient.put(params).promise();
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

const deleteTokensForUserId = async (userId) => {
  let userTokens = await getTokenForUserId(userId);
  console.log(`Found tokens: ${userTokens.Items.length}`);

  const deleteRequests = [];
  for (var i = 0; i < userTokens.Items.length; i++) {
    deleteRequests.push({
      DeleteRequest: {
        Key: {
          userId: {
            S: userTokens.Items[i].userId,
          },
          deviceToken: {
            S: userTokens.Items[i].deviceToken,
          },
        },
      },
    });
  }

  const batchWriteParams = {
    RequestItems: {
      [TABLE_NAME]: deleteRequests,
    },
  };
  return docClient.batchWrite(batchWriteParams).promise();
};

exports.handler = async (event) => {
  let statusCode = 500;
  const httpMethod = event.httpMethod;
  if (httpMethod == "DELETE") {
    const userId = event.parthParameters.userId;
    try {
      await deleteTokensForUserId(userId);
      statusCode = 200;
    } catch (error) {
      console.error(`Error deleting deviceTokens for userId: ${userId}`);
      statusCode = 500;
    }
  } else if (httpMethod == "POST") {
    const body = JSON.parse(event.body);
    if (
      "deviceToken" in body &&
      "pushProvider" in body &&
      "userId" in body &&
      (body["pushProvider"] == "APNS" || body["pushProvider"] == "FCM")
    ) {
      try {
        let { userId, deviceToken, pushProvider } = body;
        let voipToken = "";
        if ("voipToken" in body) {
          voipToken = body["voipToken"];
        }
        let result = await storeTokenForUserId(
          userId,
          deviceToken,
          pushProvider,
          voipToken
        );
        console.log(
          `Added new deviceToken for userId: ${body["userId"]} for pushProvider: ${body["pushProvider"]}`
        );
        console.log(result);
        statusCode = 201;
      } catch (error) {
        console.error(
          `Error adding new deviceToken for userId: ${body["userId"]} for pushProvider: ${body["pushProvider"]}`
        );
        console.error(error);
        statusCode = 500;
      }
    } else {
      console.error(
        `Invalid payload received while adding new deviceToken for userId: ${body["userId"]} for pushProvider: ${body["pushProvider"]}`
      );
      statusCode = 400;
    }
  }

  const response = {
    statusCode: statusCode,
  };

  return response;
};
