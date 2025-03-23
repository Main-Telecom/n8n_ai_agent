Below is an updated, streamlined version of your README file:

---

# n8n Setup and Webhook Execution

## Overview

This guide explains how to set up **n8n** and the **AI Agent** using the `webhook-setup` script. The script automates the following tasks:

- Start **n8n**, **ngrok**, and load workflows.
- Expose your local n8n instance to the internet.
- Configure external webhook integrations (e.g., Telegram,WhatsApp ).

---

## Prerequisites

Before running the script, ensure you have the following installed:

- **Node.js** (v18 or later)
- **npm** (Node Package Manager)
- **ngrok** (will be installed or configured by the script)

---

## Installation and Setup Steps

### 1. Prepare Your Credentials

- Add your credentials (API keys, webhook tokens, etc.) from the `creds.txt` file.  
- Ensure the credentials are formatted as required by your workflows.

### 2. Run the Webhook Setup Script

- The `webhook-setup` script handles the full setup process.
- When executed, the script will:
  - **Start ngrok:** Expose your local n8n server.
  - **Retrieve ngrok’s Public URL:** Capture the dynamically assigned public URL.
  - **Set and Verify the Telegram Webhook:** Configure the Telegram bot to use the public URL.
  - **Start n8n:** Launch the workflow automation platform.
  - **Clean Up:** Terminate ngrok when n8n is stopped.

**To run the script (via Windows Command Prompt or Terminal):**
```sh
webhook-setup
```

### 3. Verify n8n is Running

- Once the setup completes, access n8n at:
  ```
  http://localhost:5678
  ```

### 4. Webhook Exposure with ngrok

- The script configures **ngrok** to expose n8n’s local webhook endpoint.
- It will output a public HTTPS URL (e.g., `https://random-subdomain.ngrok.io`).
- Use this URL to connect external services to your webhook.

---

## Project Files Overview

### `AI_Agent_WhatsApp.json`

- **Purpose:** Manages WhatsApp-based AI assistant interactions.
- **Key Components:**
  - **WhatsApp Trigger:** Captures incoming messages.
  - **AI Agent Node:** Processes queries using an AI model.
  - **Vector Store:** Retrieves relevant data via Pinecone.
  - **Google Gemini Chat Model:** Generates responses.
  - **Webhook Integration:** Sends responses back through the WhatsApp API.

### `AI_Agent_Telegram.json`

- **Purpose:** Handles AI chatbot workflows on Telegram.
- **Key Components:**
  - **Telegram Trigger:** Listens for messages.
  - **AI Agent:** Processes inputs and formulates responses.
  - **Vector Store & AI Model:** Retrieves data and composes answers.
  - **Telegram API Integration:** Delivers responses to users.

### `3cx_AI_Agent.json`

- **Purpose:** Integrates an AI assistant into the **3CX** VoIP system.
- **Key Components:**
  - **Webhook Trigger:** Receives call information.
  - **AI Agent:** Processes queries related to calls.
  - **Google Speech-to-Text:** Converts audio messages to text.
  - **Response Webhook:** Sends AI-generated responses back to 3CX.

### `word_embedding.json`

- **Purpose:** Manages text embedding for improved AI responses.
- **Key Components:**
  - **Text Processing:** Reads and prepares text files.
  - **Vector Store:** Saves embeddings in Pinecone.
  - **Embeddings Model:** Utilizes Google’s text-embedding-004.
  - **Token Splitter:** Divides text into manageable segments.

### `webhook-setup`

- **Purpose:** Orchestrates the entire setup process.
- **Execution Flow:**
  - Starts **n8n** and loads credentials from `creds.txt`.
  - Configures **ngrok** to expose the n8n server.
  - Outputs the **public webhook URL** for external integrations.
  - Cleans up by stopping ngrok after n8n exits.

---

## Testing Your Webhook

1. **Execute** the `webhook-setup` script.
2. **Use** the generated ngrok URL for your external webhook settings.
3. **Send** a test request (using Postman or another tool).
4. **Check** the n8n logs to confirm that the request was received and processed.

