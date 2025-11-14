const N8N_ENDPOINT = 'https://n8n.srv1094917.hstgr.cloud/webhook-test/Oji';
const SESSION_KEY = 'oji-session-id';

/**
 * Generate or retrieve persistent session ID
 */
function getSessionId() {
  if (typeof window === 'undefined') {
    return 'session-server';
  }

  try {
    let sessionId = window.localStorage.getItem(SESSION_KEY);
    if (!sessionId) {
      if (window.crypto && window.crypto.randomUUID) {
        sessionId = window.crypto.randomUUID();
      } else {
        sessionId = `session-${Date.now()}-${Math.random().toString(16).slice(2)}`;
      }
      window.localStorage.setItem(SESSION_KEY, sessionId);
    }
    return sessionId;
  } catch (error) {
    console.warn('Unable to access localStorage for session tracking:', error);
    return `session-${Date.now()}`;
  }
}

/**
 * Convert a File to a JSON upload payload
 */
function fileToPayload(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      resolve({
        name: file.name,
        type: file.type,
        size: file.size,
        content: reader.result
      });
    };
    reader.onerror = () => reject(reader.error);
    reader.readAsDataURL(file);
  });
}

/**
 * Send message to the n8n Webhook
 */
export async function sendMessage(message, files = []) {
  const sessionId = getSessionId();

  let filePayload = [];
  if (files && files.length) {
    filePayload = await Promise.all(Array.from(files).map(fileToPayload));
  }

  //  IMPORTANT CHANGE:
  //  Your workflow expects "session_id" (snake_case), not "sessionId".
  const payload = {
    session_id: sessionId,      // <-- FIXED!
    message,
    speaker: "user",            // safe default
    project_id: "atlas",        // optional safe default
    tags: [],
    emotions: {},
    timestamp: new Date().toISOString(),
    files: filePayload
  };

  const response = await fetch(N8N_ENDPOINT, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
  });

  if (!response.ok) {
    throw new Error(`n8n webhook error: ${response.status}`);
  }

  const data = await response.json().catch(() => ({
    reply: 'Oji received the data and will respond shortly.',
    raw: null
  }));

  return data;
}
