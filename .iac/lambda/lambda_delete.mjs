import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, DeleteCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
  const blog_id = Number(event.pathParameters.blog_id);

  if (!blog_id) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Falta el parámetro blog_id" }),
    };
  }

  const command = new DeleteCommand({
    TableName: process.env.TABLE_NAME || "blogs-dev",
    Key: { blog_id },
  });

  try {
    await docClient.send(command);

    return {
      statusCode: 200,
      body: JSON.stringify({ message: `Blog con ID ${blog_id} eliminado correctamente` }),
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Error al eliminar", detalle: err.message }),
    };
  }
};