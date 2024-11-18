# Radio Station Restart Script

This script automates the process of restarting radio stations via a backend API and sends notifications of the restart status to a designated Telegram bot.

---

## Features

- Restarts specified radio stations using an API endpoint.
- Logs the restart process with timestamps.
- Sends Telegram notifications to update the user on the success or failure of each station's restart.

---

## Requirements

1. **Bash**: The script runs on any Unix-based system.
2. **`jq`**: A lightweight JSON processor for parsing API responses.
   - Install it using:
     ```bash
     sudo apt install jq
     ```
3. **`curl`**: Command-line tool for API requests (pre-installed on most Unix systems).
4. **Telegram Bot**:
   - A bot to send notifications to a user or group.
   - See the "Setup" section below for details on creating one.

---

## Setup

### 1. Get a Telegram Bot Token (`BOT_TOKEN`)

1. Open Telegram and search for `@BotFather`.
2. Start a chat with `BotFather` and use the `/newbot` command.
3. Follow the prompts to create your bot.
4. `BotFather` will provide a **Bot Token** after the bot is created. Copy this token.

### 2. Get a Telegram Chat ID (`CHAT_ID`)

#### For a Private Chat:
1. Send any message to your bot in a private chat.
2. Run this command to get updates (replace `<YOUR_BOT_TOKEN>` with your bot's token):
   ```bash
   curl -s -X GET "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates"
   ```
3. Look for `"chat":{"id":<CHAT_ID>}` in the response. Copy the value of `id`.

#### For a Group Chat:
1. Add your bot to the desired group.
2. Send any message in the group.
3. Run the same `getUpdates` command as above.
4. Look for `"chat":{"id":<CHAT_ID>, "type":"group"}`. Copy the value of `id`.

### 3. Get an API Key for Your Radio Service

- Obtain the API Key from your radio service provider. This is used to authenticate API requests for restarting stations.

---

## Configuration

Edit the script to configure these variables:

```bash
BOT_TOKEN="YOUR_BOT_TOKEN"        # Replace with your Telegram bot token
CHAT_ID="YOUR_CHAT_ID"            # Replace with your Telegram chat ID
API_KEY="YOUR_API_KEY"            # Replace with your radio API key
BASE_URL="https://stream.tujuhcahaya.com/api" # Base URL for radio API
STATION_IDS=("31" "32")           # Replace with your station IDs
```

---

## Script Usage

### Save the Script

Save the following content as `restart_radio.sh`

---

### Make the Script Executable

Run the following command to give the script execution permissions:

```bash
chmod +x restart_radio.sh
```

---

### Run the Script

Execute the script using:

```bash
./restart_radio.sh
```

Logs will be saved to `/var/log/station_restart.log`.

---

## Notes

- Ensure your **`BOT_TOKEN`**, **`CHAT_ID`**, and **`API_KEY`** are valid.
- Check your API's documentation for the correct `BASE_URL` and endpoints.
- Update `STATION_IDS` to include the IDs of the stations you want to restart.

---

Feel free to submit an issue or pull request for improvements. 🚀
