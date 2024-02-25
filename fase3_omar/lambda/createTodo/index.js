const AWS = require('aws-sdk');
const uuid = require('uuid');

const credentials = new AWS.Credentials({
    accessKeyId: process.env.ASDF_KEY_ID, 
    secretAccessKey: process.env.ASDF_SECRET_KEY,
    sessionToken: process.env.ASDF_SECRET_TOKEN
});

const dynamoDb = new AWS.DynamoDB.DocumentClient({credentials: credentials});

exports.handler = async (event) => {
    const item = JSON.parse(event.body);
    item.id = uuid.v4()

    const params = {
        TableName: process.env.TABLE_NAME,
        Item: item,
    };

    try {
        await dynamoDb.put(params).promise();
        return { statusCode: 200, body: JSON.stringify(item) };
    } catch (error) {
        console.error(error);
        return { statusCode: 500, body: JSON.stringify({ error: 'Could not create todo' }) };
    }
};
