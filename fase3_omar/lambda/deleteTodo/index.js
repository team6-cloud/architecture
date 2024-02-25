const AWS = require('aws-sdk');

const credentials = new AWS.Credentials({
    accessKeyId: process.env.ASDF_KEY_ID, 
    secretAccessKey: process.env.ASDF_SECRET_KEY,
    sessionToken: process.env.ASDF_SECRET_TOKEN
});

const dynamoDb = new AWS.DynamoDB.DocumentClient({credentials: credentials});


exports.handler = async (event) => {
    const params = {
        TableName: process.env.TABLE_NAME,
        Key: {
            id: event.pathParameters.id,
        },
    };

    try {
        await dynamoDb.delete(params).promise();
        return { statusCode: 204, body: '' }; // No content
    } catch (error) {
        console.error(error);
        return { statusCode: 500, body: JSON.stringify({ error: 'Could not delete todo' }) };
    }
};
