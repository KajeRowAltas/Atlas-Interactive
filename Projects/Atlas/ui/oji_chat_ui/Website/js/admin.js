import { openModal } from './app.js';
import { sendMessage } from './api.js';

const featureBindings = {
  'quick-actions': '#quick-actions',
  'memory-viewer': '#memory-viewer',
  'chat-history': '#chat-history',
  'file-upload': '#file-input'
};

function toggleFeature(key, enabled) {
  const selector = featureBindings[key];
  if (!selector) return;
  const element = document.querySelector(selector);
  if (!element) return;
  if (enabled) {
    element.classList.remove('hidden');
    if (selector === '#file-input') {
      const label = document.querySelector('label[for="file-input"]');
      if (label) label.classList.remove('hidden');
    }
  } else {
    element.classList.add('hidden');
    if (selector === '#file-input') {
      const label = document.querySelector('label[for="file-input"]');
      if (label) label.classList.add('hidden');
    }
  }
  localStorage.setItem(`feature-${key}`, enabled ? 'true' : 'false');

  if (key === 'memory-viewer') {
    const button = document.getElementById('open-memory');
    if (button) button.classList.toggle('hidden', !enabled);
  }
  if (key === 'chat-history') {
    const button = document.getElementById('open-history');
    if (button) button.classList.toggle('hidden', !enabled);
  }
}

document.addEventListener('components:ready', () => {
  document.querySelectorAll('[data-toggle]').forEach((checkbox) => {
    const key = checkbox.dataset.toggle;
    const stored = localStorage.getItem(`feature-${key}`);
    if (stored !== null) {
      checkbox.checked = stored === 'true';
      toggleFeature(key, checkbox.checked);
    }
    checkbox.addEventListener('change', () => {
      toggleFeature(key, checkbox.checked);
    });
  });

  const broadcastButton = document.querySelector('[data-action="broadcast"]');
  const textarea = document.getElementById('system-announcement');
  if (broadcastButton && textarea) {
    broadcastButton.addEventListener('click', () => {
      if (!textarea.value.trim()) return;
      openModal('chat-history');
      const history = document.getElementById('history-list');
      if (history) {
        const li = document.createElement('li');
        li.textContent = `Announcement · ${textarea.value.trim()}`;
        history.prepend(li);
      }
      textarea.value = '';
    });
  }

  const testButton = document.querySelector('[data-action="test-webhook"]');
  if (testButton) {
    testButton.addEventListener('click', async () => {
      testButton.disabled = true;
      testButton.textContent = 'Testing…';
      try {
        await sendMessage('Test ping from admin panel', []);
        testButton.textContent = 'Success';
        setTimeout(() => (testButton.textContent = 'Test Connection'), 2000);
      } catch (error) {
        testButton.textContent = 'Failed';
        console.error(error);
        setTimeout(() => (testButton.textContent = 'Test Connection'), 2000);
      } finally {
        testButton.disabled = false;
      }
    });
  }
});
