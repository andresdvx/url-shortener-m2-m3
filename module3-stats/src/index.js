const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand } = require("@aws-sdk/lib-dynamodb");

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
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type",
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
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type",
        },
        body: JSON.stringify({
          error: "URL no encontrada",
          code: code,
        }),
      };
    }

   
    const stats = {
      code: result.Item.code,
      originalUrl: result.Item.originalUrl,
      createdAt: result.Item.createdAt,
      totalClicks: result.Item.clicksTotal || 0,
      lastAccessed: new Date().toISOString(),
    };

    
    const queryParams = event.queryStringParameters || {};
    
    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
      },
      body: JSON.stringify({
        success: true,
        stats: stats,
        filters: queryParams,
      }),
    };
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
      },
      body: JSON.stringify({
        error: "Error interno del servidor",
        message: error.message,
      }),
    };
  }
};
