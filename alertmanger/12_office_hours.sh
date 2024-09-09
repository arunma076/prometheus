#!/bin/bash

# Define the start and end times in UTC
START_TIME=$(date -d "06:28 UTC" --utc +%Y-%m-%dT%H:%M:%SZ)  # 11:58 PM UTC today
END_TIME=$(date -d "03:35 UTC tomorrow" --utc +%Y-%m-%dT%H:%M:%SZ)  # 9:05 AM UTC tomorrow

# Define the Alertmanager API URL
SILENCE_URL="http://localhost:9093/api/v2/silences"

# Create the silence using curl
curl -X POST $SILENCE_URL \
-H "Content-Type: application/json" \
-d '{
  "matchers": [
    {
      "name": "alertname",
      "value": "10-office-hours",
      "isRegex": false
    }
  ],
  "startsAt": "'"$START_TIME"'",
  "endsAt": "'"$END_TIME"'",
  "createdBy": "alertmanager-silencer",
  "comment": "Daily silence from 11:58 PM to 9:05 AM UTC"
}'
