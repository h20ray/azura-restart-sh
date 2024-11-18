#!/bin/bash

# Configuration Variables
BOT_TOKEN="YOUR_BOT_TOKEN"           # Replace with your Telegram bot token
CHAT_ID="YOUR_CHAT_ID"               # Replace with your Telegram chat ID
API_KEY="YOUR_API_KEY"               # Replace with your radio API key
BASE_URL="https://stream.tujuhcahaya.com/api" # Base URL for radio API
LOG_FILE="/var/log/station_restart.log"
STATION_IDS=("31" "32")              # Replace with your station IDs

# Dependencies Check
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Install it using 'sudo apt install jq'."
  exit 1
fi

# Start Logging
echo "$(date '+%Y-%m-%d %H:%M:%S') Starting station restart process..." | tee -a "$LOG_FILE"

# Initialize Telegram Notification Message
NOTIFY_MESSAGE="*Station Restart Process:*\n"

# Restart Stations
for STATION_ID in "${STATION_IDS[@]}"; do
  station=$(curl -s -X GET "$BASE_URL/stations" -H "X-API-Key: $API_KEY" | jq -r --arg ID "$STATION_ID" '.[] | select(.id == ($ID|tonumber))')
  
  if [[ -n "$station" ]]; then
    STATION_NAME=$(echo "$station" | jq -r .name)
    echo "Debug: Sending restart request for $STATION_NAME (ID: $STATION_ID)" | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE_URL/station/$STATION_ID/restart" -H "X-API-Key: $API_KEY")
    if [[ "$RESPONSE" -eq 200 ]]; then
      MESSAGE="✅ *$STATION_NAME*: Restarted successfully."
      echo "$(date '+%Y-%m-%d %H:%M:%S') $MESSAGE" | tee -a "$LOG_FILE"
      NOTIFY_MESSAGE+="$MESSAGE\n"
    else
      MESSAGE="❌ *$STATION_NAME*: Failed to restart (HTTP $RESPONSE)."
      echo "$(date '+%Y-%m-%d %H:%M:%S') $MESSAGE" | tee -a "$LOG_FILE"
      NOTIFY_MESSAGE+="$MESSAGE\n"
    fi
  else
    MESSAGE="❌ Station with ID $STATION_ID not found."
    echo "$(date '+%Y-%m-%d %H:%M:%S') $MESSAGE" | tee -a "$LOG_FILE"
    NOTIFY_MESSAGE+="$MESSAGE\n"
  fi
done

# Send Telegram Notification
TELEGRAM_RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
  -d chat_id="$CHAT_ID" \
  -d text="$(echo -e "$NOTIFY_MESSAGE")" \
  -d parse_mode=Markdown)

if [[ $(echo "$TELEGRAM_RESPONSE" | jq -r .ok) == "true" ]]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') Telegram notification sent successfully." | tee -a "$LOG_FILE"
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') Telegram Error: $(echo "$TELEGRAM_RESPONSE" | jq -r .description)" | tee -a "$LOG_FILE"
fi

# End Logging
echo "$(date '+%Y-%m-%d %H:%M:%S') Station restart process completed." | tee -a "$LOG_FILE"
