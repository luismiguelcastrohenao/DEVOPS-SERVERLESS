import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, DeleteCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
  const command = new DeleteCommand({
    TableName: process.env.TABLE_NAME || "blogs-dev",
    Key: {
      blog_id : event.blog_id,
    },
  });
  try {
    const response = await docClient.send(command);
    console.log(response);
    return "Successfully deleted item!";
  } catch (err) {
    return { error: err }
  }
};





// // deleteBlogsLambda

// const AWS = require('aws-sdk');
// const docClient = new AWS.DynamoDB.DocumentClient();

// var params = {
//   TableName: process.env.TABLE_NAME || "blogs-dev",
//   Key: {
//     "blog_id": 1
//   },
//   ReturnValues: "ALL_OLD"
// }

// exports.handler = async (event, context) => {
//   try {
//     const data = await docClient.delete(params).promise()
//     return { body: JSON.stringify(data) }
//   } catch (err) {
//     return { error: err }
//   }
// }