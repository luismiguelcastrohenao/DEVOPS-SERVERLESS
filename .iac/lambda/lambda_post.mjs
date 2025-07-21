import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { PutCommand, DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
  const command = new PutCommand({
    TableName: process.env.TABLE_NAME || "blogs-dev",
    Item: {
      "blog_id": event.blog_id,
      "blog_author": event.blog_author,
      "blog_title": event.blog_title
    },
  });
  try {
    const response = await docClient.send(command);
    console.log(response);
    return "Successfully created item!";
  } catch (err) {
    return { error: err }
  }
};
