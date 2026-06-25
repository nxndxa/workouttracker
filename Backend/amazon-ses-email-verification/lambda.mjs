import { DynamoDBClient, DeleteItemCommand, GetItemCommand, PutItemCommand } from "@aws-sdk/client-dynamodb";
import { SESv2Client, SendEmailCommand } from "@aws-sdk/client-sesv2";
import crypto from "node:crypto";

const dynamo = new DynamoDBClient({});
const ses = new SESv2Client({});

const tableName = process.env.TABLE_NAME;
const fromEmail = process.env.FROM_EMAIL;
const codeSecret = process.env.CODE_SECRET;
const codeTTLSeconds = Number(process.env.CODE_TTL_SECONDS ?? "600");

export async function handler(event) {
  try {
    const route = routePath(event);
    const body = JSON.parse(event.body || "{}");

    if (route.endsWith("/request-code")) {
      return json(await requestCode(body));
    }

    if (route.endsWith("/verify-code")) {
      return json(await verifyCode(body));
    }

    return json({ message: "Not found" }, 404);
  } catch (error) {
    console.error(error);
    return json({ message: error.message || "Email verification failed." }, error.statusCode || 500);
  }
}

async function requestCode(body) {
  assertConfigured();

  const email = normalizeEmail(body.email);
  if (!email.includes("@")) {
    throw httpError("Enter a valid email address.", 400);
  }

  const code = String(crypto.randomInt(100000, 999999));
  const expiresAtSeconds = Math.floor(Date.now() / 1000) + codeTTLSeconds;

  await dynamo.send(new PutItemCommand({
    TableName: tableName,
    Item: {
      email: { S: email },
      codeHash: { S: hashCode(email, code) },
      expiresAt: { N: String(expiresAtSeconds) }
    }
  }));

  await ses.send(new SendEmailCommand({
    FromEmailAddress: fromEmail,
    Destination: {
      ToAddresses: [email]
    },
    Content: {
      Simple: {
        Subject: {
          Data: "Your Aether verification code"
        },
        Body: {
          Text: {
            Data: `Your Aether verification code is ${code}. It expires in ${Math.round(codeTTLSeconds / 60)} minutes.`
          }
        }
      }
    }
  }));

  return {
    expiresAt: new Date(expiresAtSeconds * 1000).toISOString()
  };
}

async function verifyCode(body) {
  assertConfigured();

  const email = normalizeEmail(body.email);
  const code = String(body.code || "").trim();
  if (!email.includes("@") || code.length < 4) {
    throw httpError("Enter the verification code from your email.", 400);
  }

  const result = await dynamo.send(new GetItemCommand({
    TableName: tableName,
    Key: {
      email: { S: email }
    }
  }));

  const item = result.Item;
  const expiresAt = Number(item?.expiresAt?.N ?? "0");
  const expectedHash = item?.codeHash?.S;
  const isExpired = expiresAt < Math.floor(Date.now() / 1000);
  const isMatch = expectedHash && crypto.timingSafeEqual(
    Buffer.from(expectedHash),
    Buffer.from(hashCode(email, code))
  );

  if (!item || isExpired || !isMatch) {
    throw httpError("That verification code is invalid or expired.", 401);
  }

  await dynamo.send(new DeleteItemCommand({
    TableName: tableName,
    Key: {
      email: { S: email }
    }
  }));

  return {};
}

function routePath(event) {
  return event.rawPath || event.path || "";
}

function normalizeEmail(email) {
  return String(email || "").trim().toLowerCase();
}

function hashCode(email, code) {
  return crypto
    .createHmac("sha256", codeSecret)
    .update(`${email}:${code}`)
    .digest("hex");
}

function assertConfigured() {
  if (!tableName || !fromEmail || !codeSecret) {
    throw httpError("Email verification backend is missing required environment variables.", 500);
  }
}

function httpError(message, statusCode) {
  const error = new Error(message);
  error.statusCode = statusCode;
  return error;
}

function json(body, statusCode = 200) {
  return {
    statusCode,
    headers: {
      "content-type": "application/json"
    },
    body: JSON.stringify(body)
  };
}
