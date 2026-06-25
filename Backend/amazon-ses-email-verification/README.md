# Aether Amazon SES Email Verification

This is a small backend starter for Aether's email login flow. The iOS app calls this backend; the backend sends email through Amazon SES and verifies the one-time code.

Do not call SES directly from the iPhone app. That would expose AWS credentials.

## Endpoints

Deploy the Lambda behind API Gateway or Lambda Function URLs with these paths:

- `POST /request-code`
- `POST /verify-code`

`/request-code` body:

```json
{
  "email": "user@example.com",
  "displayName": "Nandha"
}
```

`/request-code` response:

```json
{
  "expiresAt": "2026-06-23T18:00:00.000Z"
}
```

`/verify-code` body:

```json
{
  "email": "user@example.com",
  "code": "123456"
}
```

`/verify-code` response:

```json
{}
```

## AWS resources

Create:

- An SES verified sender identity for `FROM_EMAIL`.
- A DynamoDB table with partition key `email` as a string.
- A Lambda function using `lambda.mjs`.
- IAM permissions for the Lambda to call `ses:SendEmail`, `dynamodb:PutItem`, `dynamodb:GetItem`, and `dynamodb:DeleteItem`.

Lambda environment variables:

- `TABLE_NAME`: DynamoDB table name.
- `FROM_EMAIL`: verified SES sender address.
- `CODE_SECRET`: long random secret used to hash verification codes.
- `CODE_TTL_SECONDS`: optional, defaults to `600`.

## iOS configuration

After deployment, set the app Info value `AetherAuthBaseURL` in `Aether.xcodeproj` to the deployed base URL, for example:

```text
https://abc123.execute-api.us-west-2.amazonaws.com
```

The app appends `/request-code` and `/verify-code` automatically.
