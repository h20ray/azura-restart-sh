# Radio Station Restart Script

This script automates the process of restarting radio stations via a backend API and sends notifications of the restart status to a designated Telegram bot. Additionally, it is designed to be integrated with `cron` for scheduled, automatic restarts.

---

## **Features**

- Automatically restarts specified radio stations using an API endpoint.
- Logs the entire process with timestamps for debugging and auditing.
- Sends detailed Telegram notifications to a user or group about the restart status.
- Easily configurable for automated periodic execution via `cron`.

---

## **Requirements**

1. **Bash**: The script runs on Unix-based systems (Linux, macOS, WSL on Windows).
2. **`jq`**: A lightweight JSON processor for parsing API responses.
   - Install with:
     ```bash
     sudo apt install jq
     ```
3. **`curl`**: Command-line tool for making API requests (pre-installed on most Unix systems).
4. **Telegram Bot**:
   - A bot to send notifications to a user or group.
   - See the "Setup" section for steps to create and configure a Telegram bot.

---

## **Setup**

### **Step 1: Get a Telegram Bot Token (`BOT_TOKEN`)**

1. Open Telegram and search for `@BotFather`.
2. Start a chat and use the `/newbot` command.
3. Follow the instructions to create your bot.
4. `BotFather` will provide a **Bot Token** upon bot creation. Save this token securely.

---

### **Step 2: Get a Telegram Chat ID (`CHAT_ID`)**

#### For a Private Chat:
1. Send any message to your bot in a private chat.
2. Run the following command to get updates (replace `<YOUR_BOT_TOKEN>` with your actual token):
   ```bash
   curl -s -X GET "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates"
   ```
3. Look for `"chat":{"id":<CHAT_ID>}` in the response. Copy the `id`.

#### For a Group Chat:
1. Add your bot to the group.
2. Send any message in the group.
3. Run the `getUpdates` command again.
4. Look for `"chat":{"id":<CHAT_ID>, "type":"group"}`. Copy the group `id`.

---

### **Step 3: Obtain API Key for Your Radio Service**

- Contact your radio service provider to get an **API Key**. This key will authenticate your requests to the radio API.

---

## **Download and Configure the Script**

### **Step 1: Download the Script**

Download the script directly from GitHub:

```bash
curl -O https://github.com/h20ray/azura-restart-sh/blob/main/restart_radio.sh
```

### **Step 2: Make the Script Executable**

Run the following command to give the script execution permissions:

```bash
chmod +x restart_radio.sh
```

---

### **Step 3: Configure the Script**

Edit the script to update the following variables:

```bash
BOT_TOKEN="YOUR_BOT_TOKEN"        # Replace with your Telegram bot token
CHAT_ID="YOUR_CHAT_ID"            # Replace with your Telegram chat ID
API_KEY="YOUR_API_KEY"            # Replace with your radio API key
BASE_URL="https://stream.tujuhcahaya.com/api" # Base URL for radio API
STATION_IDS=("31" "32")           # Replace with your station IDs
```

You can edit the file using any text editor, e.g., `nano`:

```bash
nano restart_radio.sh
```

---

## **Schedule Automatic Restarts with `cron`**

1. Open the `crontab` editor:
   ```bash
   crontab -e
   ```

2. Add an entry to schedule the script (e.g., to run every day at 3 AM):
   ```bash
   0 3 * * * /path/to/restart_radio.sh
   ```

3. Save and exit the editor.

To verify the `cron` job is set up correctly:
```bash
crontab -l
```

Logs will be generated for each execution and saved to `/var/log/station_restart.log`.

---

## **Usage**

### **Make the Script Executable**

```bash
chmod +x restart_radio.sh
```

### **Run the Script Manually**

```bash
./restart_radio.sh
```

### **Check Logs**

View the log file for detailed output:

```bash
cat /var/log/station_restart.log
```

---

## **Example**

### **Sample Output in Log File**

```plaintext
2024-11-18 21:39:06 Starting station restart process...
2024-11-18 21:39:17 ✅ *Radio Delta Semarang*: Restarted successfully.
2024-11-18 21:39:29 ✅ *Radio Prambors Semarang*: Restarted successfully.
2024-11-18 21:39:30 Telegram notification sent successfully.
2024-11-18 21:39:30 Station restart process completed.
```

### **Telegram Notification**

The following message is sent to the Telegram chat:

```plaintext
*Station Restart Process:*
✅ *Radio Delta Semarang*: Restarted successfully.
✅ *Radio Prambors Semarang*: Restarted successfully.
```

---

## **Script Workflow**

1. **Check for Dependencies**:
   - Ensures `jq` is installed, exiting with an error if missing.

2. **Log Initialization**:
   - Logs the process start timestamp to `/var/log/station_restart.log`.

3. **Fetch Station Information**:
   - Retrieves station details from the API.

4. **Restart Stations**:
   - Sends restart requests to the API for each station ID.
   - Logs success or failure for each request.

5. **Send Telegram Notification**:
   - Sends a summary message to the configured Telegram chat.

6. **End Logging**:
   - Logs the process completion timestamp.

---

## **Error Handling**

- Missing dependencies (`jq`): The script exits with an error message.
- API errors (e.g., 401, 500): Logs the error and includes it in Telegram notifications.
- Invalid `BOT_TOKEN` or `CHAT_ID`: Telegram API returns a detailed error message.

---

## **Security Considerations**

- **Secure Your Tokens and Keys**:
  - Store sensitive information like `BOT_TOKEN` and `API_KEY` in environment variables or secure configuration files.
- **Restrict Access**:
  - Ensure the script is only accessible by authorized users.

---

## **Troubleshooting**

1. **Telegram Notifications Not Working**:
   - Verify `BOT_TOKEN` and `CHAT_ID`.
   - Test the Telegram bot separately using `curl` to confirm functionality.

2. **Station Not Restarting**:
   - Ensure `STATION_IDS` are correct.
   - Verify the API endpoint and `API_KEY`.

3. **Log File Not Found**:
   - Check that `/var/log/station_restart.log` is writable.
   - Run the script with sufficient permissions.

---

## **Support**

If you encounter issues, feel free to open an issue or pull request on the [GitHub repository](https://github.com/h20ray/azura-restart-sh).

Automate your radio station management today! 🚀
