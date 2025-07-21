import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
  const command = new GetCommand({
    TableName: process.env.TABLE_NAME || "blogs-dev",
    Key: {
      blog_id : event.blog_id,
    },
  });

  const response = await docClient.send(command);
  console.log(response);
  return response;
};
