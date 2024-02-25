const AWS = require('aws-sdk');

const credentials = new AWS.Credentials({
    accessKeyId: process.env.ASDF_KEY_ID, 
    secretAccessKey: process.env.ASDF_SECRET_KEY,
    sessionToken: process.env.ASDF_SECRET_TOKEN
});

const dynamoDb = new AWS.DynamoDB.DocumentClient({credentials: credentials});

exports.handler = async (event) => {
    const requestBody = JSON.parse(event.body);
    const updateKeys = Object.keys(requestBody);
    const updateExpression = "set " + updateKeys.map(key => `${key} = :${key}`).join(", ");
    const expressionAttributeValues = {};
    updateKeys.forEach(key => expressionAttributeValues[`:${key}`] = requestBody[key]);

    const params = {
        TableName: process.env.TABLE_NAME,
        Key: {
            id: event.pathParameters.id,
        },
        UpdateExpression: updateExpression,
        ExpressionAttributeValues: expressionAttributeValues,
        ReturnValues: "UPDATED_NEW",
    };

    try {
        const data = await dynamoDb.update(params).promise();
        return { statusCode: 200, body: JSON.stringify(data.Attributes) };
    } catch (error) {
        console.error(error);
        return { statusCode: 500, body: JSON.stringify({ error: 'Could not update todo' }) };
    }
};
