# aws-aai-grocery-guy
AWS Agentic AI Grocery Management

The system is designed to be deployed on AWS using Lambda functions, API Gateway, and DynamoDB. Each agent is implemented as a separate Lambda function. API Gateway is used to expose the Lambda functions as REST APIs. DynamoDB is used to store the grocery inventory. The workflow is as follows:

The user uploads a grocery receipt image to the API Gateway endpoint.
The API Gateway triggers the Receipt Interpreter Agent Lambda function.
The Receipt Interpreter Agent extracts the items from the receipt and stores them in DynamoDB.
The API Gateway triggers the Expiration Date Estimation Agent Lambda function.
The Expiration Date Estimation Agent estimates the expiration dates of the items and stores them in DynamoDB.
The user consumes items from the grocery inventory.
The user updates the grocery inventory via the API Gateway endpoint.
The API Gateway triggers the Grocery Tracker Agent Lambda function.
The Grocery Tracker Agent updates the grocery inventory in DynamoDB.
The API Gateway triggers the Recipe Recommendation Agent Lambda function.
The Recipe Recommendation Agent recommends recipes based on the remaining items in the grocery inventory.
The user views the recipe recommendations via the API Gateway endpoint.
