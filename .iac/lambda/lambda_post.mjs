import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { PutCommand, DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
  try {
    // Parsear el body JSON
    const body = JSON.parse(event.body || "{}");

    // Validación mínima
    if (!body.blog_id || !body.blog_author || !body.blog_title) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: "Faltan campos obligatorios: blog_id, blog_author, blog_title" }),
      };
    }

    const command = new PutCommand({
      TableName: process.env.TABLE_NAME || "blogs-dev",
      Item: {
        blog_id: body.blog_id, // debe ser number si así lo definiste
        blog_author: body.blog_author,
        blog_title: body.blog_title
      },
    });

    await docClient.send(command);

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Item creado exitosamente" }),
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.message }),
    };
  }
};
