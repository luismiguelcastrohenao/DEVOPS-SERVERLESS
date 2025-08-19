import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
  const blog_id = Number(event.queryStringParameters?.blog_id);

  if (!blog_id) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Falta el parámetro blog_id" }),
    };
  }

  const command = new GetCommand({
    TableName: process.env.TABLE_NAME || "blogs-dev",
    Key: { blog_id },
  });

  try {
    const response = await docClient.send(command);

    if (!response.Item) {
      return {
        statusCode: 404,
        body: JSON.stringify({ error: "Blog no encontrado" }),
      };
    }

    return {
      statusCode: 200,
      body: JSON.stringify(response.Item),
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Error interno:22", detalle: err.message }),
    };
  }
};