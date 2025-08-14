#!/bin/bash
BOOTSTRAP=$1
TOPICS_STRING=$2
REPLICATION_FACTOR=$3
PARTITIONS=$4
SECRET_ARN=$5

IFS=',' read -ra TOPICS <<< "$TOPICS_STRING"

# Get credentials from AWS Secrets Manager
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id $SECRET_ARN --query SecretString --output text)
USERNAME=$(echo $SECRET_JSON | jq -r '.username')
PASSWORD=$(echo $SECRET_JSON | jq -r '.password')

# Create client.properties dynamically
cat > /tmp/client.properties << EOF
security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="${USERNAME}" password="${PASSWORD}";
EOF

for t in "${TOPICS[@]}"; do
    kafka-topics.sh \
        --create \
        --bootstrap-server $BOOTSTRAP \
        --command-config /tmp/client.properties \
        --replication-factor $REPLICATION_FACTOR \
        --partitions $PARTITIONS \
        --topic "$t"
done

# Cleanup
rm -f /tmp/client.properties