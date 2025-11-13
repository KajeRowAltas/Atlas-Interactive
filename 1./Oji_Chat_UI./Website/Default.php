<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oji Simple Chat Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f4f4f4; }
        #chat { border: 1px solid #ccc; height: 400px; overflow-y: scroll; padding: 10px; background: white; margin-bottom: 10px; }
        .message { margin: 5px 0; padding: 8px; border-radius: 5px; }
        .user { background: #007bff; color: white; text-align: right; }
        .bot { background: #e9ecef; color: #333; }
        #input-area { display: flex; gap: 10px; }
        #user-input { flex: 1; padding: 10px; border: 1px solid #ccc; border-radius: 5px; }
        #send-btn { padding: 10px 20px; background: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; }
        #send-btn:disabled { background: #ccc; cursor: not-allowed; }
    </style>
</head>
<body>
    <h1>Oji Simple Chat Test</h1>
    <div id="chat"></div>
    <div id="input-area">
        <input type="text" id="user-input" placeholder="Type your message..." />
        <button id="send-btn" onclick="sendMessage()">Send</button>
    </div>

    <script>
        // Use test URL for now; switch to 'https://n8n.srv1094917.hstgr.cloud/webhook/Oji' for production
        const webhookUrl = 'https://n8n.srv1094917.hstgr.cloud/webhook-test/Oji';
        const sessionId = localStorage.getItem('oji_session') || crypto.randomUUID();
        localStorage.setItem('oji_session', sessionId);
        const chatDiv = document.getElementById('chat');
        const input = document.getElementById('user-input');
        const sendBtn = document.getElementById('send-btn');

        function addMessage(text, isUser) {
            const msg = document.createElement('div');
            msg.className = `message ${isUser ? 'user' : 'bot'}`;
            msg.textContent = (isUser ? 'You: ' : 'Oji: ') + text;
            chatDiv.appendChild(msg);
            chatDiv.scrollTop = chatDiv.scrollHeight;
        }

        async function sendMessage() {
            const userMessage = input.value.trim();
            if (!userMessage) return;

            addMessage(userMessage, true);
            input.value = '';
            sendBtn.disabled = true;
            sendBtn.textContent = 'Sending...';

            try {
                const response = await fetch(webhookUrl, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ message: userMessage, session_id: sessionId })
                });

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }

                const data = await response.json();
                console.log('Full server response:', data);  // Debug: Check console!

                // Handle n8n array output: Access first item safely
                const replyText = data[0]?.response || data.response || data.reply || data.oji_response || 'No reply key found.';
                addMessage(replyText, false);
            } catch (error) {
                console.error('Error:', error);
                addMessage('Error: ' + error.message, false);
            } finally {
                sendBtn.disabled = false;
                sendBtn.textContent = 'Send';
                input.focus();
            }
        }

        // Enter key to send
        input.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') sendMessage();
        });

        // Initial welcome
        addMessage('Hello! Send a message to test Oji.', false);
    </script>
</body>
</html>
