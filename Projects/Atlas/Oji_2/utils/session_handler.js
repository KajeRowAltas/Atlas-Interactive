/**
 * Minimal session utilities for n8n Function nodes.
 */
const { generateSessionId } = require('./common_functions');

function resolveSessionId(previous) {
  if (previous && typeof previous === 'string' && previous.startsWith('oji-')) return previous;
  return generateSessionId();
}

function ensurePayload(item) {
  return item.json || item;
}

module.exports = { resolveSessionId, ensurePayload };
