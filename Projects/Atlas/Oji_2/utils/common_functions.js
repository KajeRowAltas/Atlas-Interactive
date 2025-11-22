/**
 * Shared helpers for Oji workflows.
 */

const crypto = require('crypto');

function slugify(text) {
  return text.toString().toLowerCase().replace(/\s+/g, '-').replace(/[^\w-]+/g, '').slice(0, 32);
}

function generateSessionId() {
  return `oji-${Date.now().toString(36)}-${crypto.randomBytes(2).toString('hex')}`;
}

function mergeMemories(payloads) {
  return payloads.filter(Boolean).flat();
}

function buildChatRecord({ sessionId, userMessage, assistantMessage, analysis }) {
  return {
    sessionId,
    userMessage,
    assistantMessage,
    analysis,
    timestamp: new Date().toISOString(),
  };
}

module.exports = { slugify, generateSessionId, mergeMemories, buildChatRecord };
