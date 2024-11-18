#!/bin/bash

# Konfigurasi Awal
# Ganti ini sama data kamu
BOT_TOKEN="YOUR_BOT_TOKEN"           # Token bot Telegram kamu
CHAT_ID="YOUR_CHAT_ID"               # ID chat Telegram (pribadi atau grup)
API_KEY="YOUR_API_KEY"               # API Key buat akses API radio
BASE_URL="https://stream.tujuhcahaya.com/api" # URL API radio
LOG_FILE="/var/log/station_restart.log" # File buat nyimpen log proses
STATION_IDS=("31" "32")              # ID stasiun radio yang mau direstart

# Cek Kebutuhan
# Pastikan 'jq' udah ke-install. Pastikan  udah ke install.
if ! command -v jq &> /dev/null; then
  echo "Error: jq belum ke-install. Pasang dulu pake 'sudo apt install jq'."
  exit 1
fi

# Mulai Proses
# Catat waktu mulai biar ada jejak digitalnya.
echo "$(date '+%Y-%m-%d %H:%M:%S') Lagi mulai restart stasiun nih..." | tee -a "$LOG_FILE"

# Siapin Pesan Notifikasi
# Biar nanti pas selesai, langsung kirim notif ke Telegram.
NOTIFY_MESSAGE="*Proses Restart Stasiun:*\n"

# Restart Stasiun
# Looping tiap stasiun yang ada di STATION_IDS.
for STATION_ID in "${STATION_IDS[@]}"; do
  # Ambil info stasiun dari API, pake ID-nya.
  station=$(curl -s -X GET "$BASE_URL/stations" -H "X-API-Key: $API_KEY" | jq -r --arg ID "$STATION_ID" '.[] | select(.id == ($ID|tonumber))')
  
  if [[ -n "$station" ]]; then
    # Kalau ketemu, ambil nama stasiunnya.
    STATION_NAME=$(echo "$station" | jq -r .name)
    echo "Debug: Lagi restart $STATION_NAME (ID: $STATION_ID)..." | tee -a "$LOG_FILE"
    # Kirim permintaan restart ke API.
    RESPONSE=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE_URL/station/$STATION_ID/restart" -H "X-API-Key: $API_KEY")
    if [[ "$RESPONSE" -eq 200 ]]; then
      # Kalau sukses, bikin pesan sukses.
      MESSAGE="✅ *$STATION_NAME*: Udah sukses direstart!"
      echo "$(date '+%Y-%m-%d %H:%M:%S') $MESSAGE" | tee -a "$LOG_FILE"
      NOTIFY_MESSAGE+="$MESSAGE\n"
    else
      # Kalau gagal, bikin pesan error.
      MESSAGE="❌ *$STATION_NAME*: Gagal restart (HTTP $RESPONSE)."
      echo "$(date '+%Y-%m-%d %H:%M:%S') $MESSAGE" | tee -a "$LOG_FILE"
      NOTIFY_MESSAGE+="$MESSAGE\n"
    fi
  else
    # Kalau ID nggak ada, kasih tau error.
    MESSAGE="❌ Stasiun dengan ID $STATION_ID nggak ketemu."
    echo "$(date '+%Y-%m-%d %H:%M:%S') $MESSAGE" | tee -a "$LOG_FILE"
    NOTIFY_MESSAGE+="$MESSAGE\n"
  fi
done

# Kirim Notifikasi Telegram
TELEGRAM_RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
  -d chat_id="$CHAT_ID" \
  -d text="$(echo -e "$NOTIFY_MESSAGE")" \
  -d parse_mode=Markdown)

if [[ $(echo "$TELEGRAM_RESPONSE" | jq -r .ok) == "true" ]]; then
  # Kalau sukses, tulis di log.
  echo "$(date '+%Y-%m-%d %H:%M:%S') Notifikasi Telegram berhasil dikirim!" | tee -a "$LOG_FILE"
else
  # Kalau error, kasih tau deskripsinya.
  echo "$(date '+%Y-%m-%d %H:%M:%S') Telegram Error: $(echo "$TELEGRAM_RESPONSE" | jq -r .description)" | tee -a "$LOG_FILE"
fi

# Selesai
# Tutup proses
echo "$(date '+%Y-%m-%d %H:%M:%S') Proses restart stasiun kelar bung!" | tee -a "$LOG_FILE"
