# Deploying to AWS Lambda

This backend is configured for deployment to AWS Lambda using the AWS SAM (Serverless Application Model).

## Prerequisites

1. [AWS CLI](https://aws.amazon.com/cli/) configured with your credentials.
2. [AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html) installed.
3. Python 3.12 (as specified in `template.yaml`).

## Deployment Steps

1. **Build the application**:
   ```bash
   sam build
   ```
   *Note: SAM will use `requirements.txt` to package your dependencies.*

2. **Deploy to AWS**:
   ```bash
   sam deploy --guided
   ```
   Follow the prompts to configure your stack name, region, and other parameters.

## Local Testing

You can run the API locally in a Lambda-like environment using:
```bash
sam local start-api
```
The API will be available at `http://127.0.0.1:3000`.

## Architecture Note

- **FastAPI + Mangum**: We use the `mangum` library to wrap our FastAPI application, allowing it to handle AWS Lambda events (API Gateway, HTTP API, or Lambda Function URL).
- **template.yaml**: This file defines the AWS resources (Lambda function and HTTP API) required for the deployment.
