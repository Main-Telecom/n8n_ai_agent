@echo off
REM Telegram Webhook Setup Script with ngrok and n8n

REM -- Check if necessary tools are installed --
where ngrok >nul 2>&1
if errorlevel 1 (
    echo Error: ngrok is not installed. Please install it first.
    exit /b 1
)

where curl >nul 2>&1
if errorlevel 1 (
    echo Error: curl is not installed. Please install it first.
    exit /b 1
)

where n8n >nul 2>&1
if errorlevel 1 (
    echo Warning: n8n might not be installed. The script will continue but may fail at the last step.
)

REM -- Configuration --
set "N8N_PORT=5678"

REM -- Use provided bot token --
set "BOT_TOKEN=8035402666:AAGjiOQmUh5xMse48L_xvd8-hl3044aT4JQ"
echo Using the predefined Telegram Bot Token

REM -- Step 1: Start ngrok in a new window --
echo Step 1: Starting ngrok on port %N8N_PORT% in a new window...
start "ngrok" cmd /k ngrok http %N8N_PORT%

echo Waiting for ngrok to initialize (5 seconds)...
timeout /t 5 /nobreak >nul

REM -- Step 2: Get the ngrok URL --
for /f "delims=" %%i in ('powershell -Command "(Invoke-RestMethod 'http://localhost:4040/api/tunnels').tunnels[0].public_url"') do set "NGROK_URL=%%i"

if "%NGROK_URL%"=="" (
    echo Error: Could not retrieve ngrok URL. Check if ngrok is running properly.
    exit /b 1
)
echo Step 2: ngrok URL obtained: %NGROK_URL%

REM -- Step 3: Set the WEBHOOK_URL environment variable --
set "WEBHOOK_URL=%NGROK_URL%"
echo Step 3: WEBHOOK_URL set to: %WEBHOOK_URL%

REM -- Step 4: Set up the Telegram Webhook --
echo Step 4: Setting up Telegram webhook...
for /f "delims=" %%i in ('curl -s -X POST https://api.telegram.org/bot%BOT_TOKEN%/setWebhook -H "Content-Type: application/json" -d "{\"url\": \"%NGROK_URL%\"}"') do set "TELEGRAM_WEBHOOK=%%i"
echo Telegram webhook setup response: %TELEGRAM_WEBHOOK%

REM -- Step 5: Verify the Webhook --
echo Step 5: Verifying Telegram webhook...
for /f "delims=" %%i in ('curl -s -X GET https://api.telegram.org/bot%BOT_TOKEN%/getWebhookInfo') do set "WEBHOOK_INFO=%%i"
echo Webhook verification response: %WEBHOOK_INFO%

REM -- Step 6: Start n8n in the SAME window --
echo Step 6: Starting n8n in the same window...
n8n start

REM -- Cleanup: When n8n exits, clean up ngrok --
echo.
echo 🔴 Stopping ngrok...
taskkill /F /IM ngrok.exe >nul 2>&1
echo ngrok stopped. Exiting...
exit /b 0
