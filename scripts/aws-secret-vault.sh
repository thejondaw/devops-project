# Setup AWS secrets in Vault
kubectl exec -it vault-0 -n vault -- /bin/sh
vault login <твой root token>

# Enable AWS secrets engine
vault secrets enable aws

# Config AWS provider 
vault write aws/config/root \
  access_key=$AWS_ACCESS_KEY_ID \
  secret_key=$AWS_SECRET_ACCESS_KEY \
  region=us-east-2

# Create role for reading RDS secrets
vault write aws/roles/rds-creds \
  credential_type=iam_user \
  policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "arn:aws:secretsmanager:us-east-2:*:secret:*"
    }
  ]
}
EOF