#!/bin/bash

# Telegram Webhook Setup Script with ngrok and n8n

# Check if necessary tools are installed
command -v ngrok >/dev/null 2>&1 || { echo "Error: ngrok is not installed. Please install it first."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "Error: curl is not installed. Please install it first."; exit 1; }
command -v n8n >/dev/null 2>&1 || { echo "Warning: n8n might not be installed. The script will continue but may fail at the last step."; }

# Configuration
N8N_PORT=5678

# Get Telegram Bot Token from command line argument
if [ $# -eq 1 ]; then
    BOT_TOKEN="$1"
    echo "Using provided bot token"
else
    # If no argument is provided, prompt the user
    read -p "Enter your Telegram Bot Token: " BOT_TOKEN
fi

# Validate that a token was provided
if [ -z "$BOT_TOKEN" ]; then
    echo "Error: No bot token provided. Please run the script with your token as an argument or enter it when prompted."
    exit 1
fi

# Step 1: Start ngrok
echo "Step 1: Starting ngrok on port $N8N_PORT..."
ngrok http $N8N_PORT > /dev/null &
NGROK_PID=$!

# Wait for ngrok to start
echo "Waiting for ngrok to initialize (5 seconds)..."
sleep 5

# Step 2: Get the ngrok URL
NGROK_URL=$(curl -s localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | grep -o 'http[^"]*')

if [ -z "$NGROK_URL" ]; then
    echo "Error: Could not retrieve ngrok URL. Check if ngrok is running properly."
    kill $NGROK_PID
    exit 1
fi

echo "Step 2: ngrok URL obtained: $NGROK_URL"

# Step 3: Set the WEBHOOK_URL environment variable
export WEBHOOK_URL="$NGROK_URL"
echo "Step 3: WEBHOOK_URL set to: $WEBHOOK_URL"

# Step 4: Set up the Telegram Webhook
echo "Step 4: Setting up Telegram webhook..."
TELEGRAM_WEBHOOK=$(curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/setWebhook \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"$NGROK_URL\"}")
echo "Telegram webhook setup response: $TELEGRAM_WEBHOOK"

# Step 5: Verify the Webhook
echo "Step 5: Verifying Telegram webhook..."
WEBHOOK_INFO=$(curl -s -X GET https://api.telegram.org/bot$BOT_TOKEN/getWebhookInfo)
echo "Webhook verification response: $WEBHOOK_INFO"

# Step 6: Start n8n in the background
echo "Step 6: Starting n8n in the background..."
n8n start > n8n.log 2>&1 &
N8N_PID=$!

# Wait for n8n to initialize
echo "Waiting for n8n to initialize (10 seconds)..."
sleep 10

# Step 7: Actually check the webhook with n8n running
echo "Step 7: Checking webhook with n8n running..."
WEBHOOK_CHECK=$(curl -s -X POST $NGROK_URL/webhook/telegram)
echo "Webhook check response: $WEBHOOK_CHECK"

# Now bring n8n to the foreground by following its logs
echo ""
echo "Setup complete! All steps executed successfully."
echo "Your webhook is configured at: $NGROK_URL/webhook/telegram"
echo ""
echo "Showing n8n logs (press Ctrl+C to stop):"
tail -f n8n.log

# When user presses Ctrl+C, clean up
trap "echo 'Stopping services...'; kill $N8N_PID; kill $NGROK_PID; echo 'Services stopped.'; exit 0" INT
wait $N8N_PID

# If n8n exits on its own
echo "n8n stopped. Cleaning up ngrok..."
kill $NGROK_PID
echo "Done."
