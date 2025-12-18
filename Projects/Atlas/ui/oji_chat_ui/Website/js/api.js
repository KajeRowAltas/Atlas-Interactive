/**
 * @file api.js
 * @description Professionalized API client for sending messages and files to an n8n webhook.
 *              Automatically manages session ID via localStorage for persistence across calls.
 *              No changes required to calling code; session ID is handled internally.
 * @author Grok (xAI)
 * @version 2.0.0
 * @date 2025-11-15
 */

// Configuration
const N8N_ENDPOINT = 'https://n8n.srv1094917.hstgr.cloud/webhook-test/Oji';
const SESSION_KEY = 'webhookSessionId';

/**
 * Generates a simple UUID v4 for session ID if none exists.
 * @returns {string} A UUID string.
 */
function generateSessionId() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

/**
 * Retrieves or generates a session ID, storing it in localStorage for persistence.
 * @returns {string} The session ID.
 */
function getSessionId() {
  let sessionId = localStorage.getItem(SESSION_KEY);
  if (!sessionId) {
    sessionId = generateSessionId();
    localStorage.setItem(SESSION_KEY, sessionId);
  }
  return sessionId;
}

/**
 * Converts a File object to a payload object with base64-encoded content.
 * @param {File} file - The file to process.
 * @returns {Promise<Object>} Resolved with file metadata and content.
 * @throws {Error} If file reading fails.
 */
function fileToPayload(file) {
  return new Promise((resolve, reject) => {
    if (!(file instanceof File)) {
      return reject(new Error('Invalid file object provided.'));
    }

    const reader = new FileReader();
    reader.onload = () => {
      resolve({
        name: file.name,
        type: file.type,
        size: file.size,
        content: reader.result // Base64 DataURL
      });
    };
    reader.onerror = () => reject(new Error(`Failed to read file: ${reader.error?.message || 'Unknown error'}`));
    reader.readAsDataURL(file);
  });
}

/**
 * Sends a message with optional files to the n8n webhook.
 * Includes session ID automatically for tracking.
 * 
 * @param {string} text - The message text to send.
 * @param {FileList|File[]} [files=[]] - Optional files to attach.
 * @returns {Promise<Object>} Response data from the webhook (e.g., { reply: string, raw: any }).
 * @throws {Error} On network/HTTP errors or invalid inputs.
 * 
 * @example
 * sendMessage('Hello, world!').then(data => console.log(data.reply));
 * 
 * const files = document.querySelector('input[type="file"]').files;
 * sendMessage('Check these files!', files).then(data => console.log(data.reply));
 */
async function sendMessage(text, files = []) {
  // Input validation
  if (typeof text !== 'string' || text.trim().length === 0) {
    throw new Error('Message text is required and must be a non-empty string.');
  }
  if (!Array.isArray(files) && !(files instanceof FileList)) {
    throw new Error('Files must be an array or FileList.');
  }

  // Prepare base payload
  const payload = {
    message: text.trim(),
    timestamp: new Date().toISOString(),
    session_id: getSessionId(), // Canonical snake_case (Mongo index + backend contract)
    sessionId: getSessionId(), // Back-compat for older n8n nodes/prompts
    files: []
  };

  // Process files if provided
  if (files.length > 0) {
    try {
      payload.files = await Promise.all(
        Array.from(files).map(file => fileToPayload(file))
      );
    } catch (error) {
      console.error('File processing error:', error);
      throw new Error(`Failed to process files: ${error.message}`);
    }
  }

  // Send request
  try {
    const response = await fetch(N8N_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    });

    if (!response.ok) {
      throw new Error(`Webhook request failed: ${response.status} ${response.statusText}`);
    }

    // Parse response with fallback
    const data = await response.json().catch(() => ({
      reply: 'Oji received the data and will respond shortly.',
      raw: null
    }));

    return data;
  } catch (error) {
    if (error.name === 'TypeError' && error.message.includes('fetch')) {
      throw new Error('Network error: Unable to reach the webhook endpoint.');
    }
    throw error;
  }
}

// Export for module usage
export { sendMessage };

// Export for CommonJS (if needed)
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { sendMessage };
}
