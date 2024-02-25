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
        const { Item } = await dynamoDb.get(params).promise();
        return Item ? { statusCode: 200, body: JSON.stringify(Item) } : { statusCode: 404, body: JSON.stringify({ error: 'Todo not found' }) };
    } catch (error) {
        console.error(error);
        return { statusCode: 500, body: JSON.stringify({ error: 'Could not fetch todo' }) };
    }
};
