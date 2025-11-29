const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, UpdateCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.TABLE_NAME || "url_shortener";

exports.handler = async (event) => {
  console.log("Event:", JSON.stringify(event, null, 2));

  try {
    
    const code = event.pathParameters?.code;

    if (!code) {
      return {
        statusCode: 400,
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          error: "Código no proporcionado",
        }),
      };
    }

   
    const getCommand = new GetCommand({
      TableName: TABLE_NAME,
      Key: {
        code: code,
      },
    });

    const result = await docClient.send(getCommand);

    if (!result.Item) {
      return {
        statusCode: 404,
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          error: "URL no encontrada",
          code: code,
        }),
      };
    }

  
    const updateCommand = new UpdateCommand({
      TableName: TABLE_NAME,
      Key: {
        code: code,
      },
      UpdateExpression: "SET clicksTotal = if_not_exists(clicksTotal, :start) + :inc",
      ExpressionAttributeValues: {
        ":inc": 1,
        ":start": 0,
      },
      ReturnValues: "UPDATED_NEW",
    });

    await docClient.send(updateCommand);

  
    return {
      statusCode: 302,
      headers: {
        Location: result.Item.originalUrl,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: "Redirigiendo...",
        url: result.Item.originalUrl,
      }),
    };
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        error: "Error interno del servidor",
        message: error.message,
      }),
    };
  }
};
