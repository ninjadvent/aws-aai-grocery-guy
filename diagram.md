graph LR
A[User] --> B(API Gateway)
B --> C{{Receipt Interpreter Lambda}}
B --> D{{Grocery Tracker Lambda}}
B --> E{{Recipe Recommendation Lambda}}
C --> F(DynamoDB)
D --> F
E --> F
F --> G{{Expiration Date Estimation Lambda}}
G --> F
H[S3 Bucket ] --> C