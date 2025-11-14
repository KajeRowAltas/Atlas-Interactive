import { sendMessage } from './api.js';
import { inlineHeroicons, openModal } from './app.js';

let chatWindow;
let chatForm;
let messageInput;
let fileInput;
let quickActionContainer;
let historyList;
let sendButton;
let isSending = false;

function scrollToBottom() {
  if (chatWindow) {
    chatWindow.scrollTo({ top: chatWindow.scrollHeight, behavior: 'smooth' });
  }
}

function formatTime(date) {
  return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

function formatFileSize(bytes) {
  if (!Number.isFinite(bytes) || bytes <= 0) {
    return '—';
  }
  const units = ['B', 'KB', 'MB', 'GB'];
  const exponent = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1);
  const value = bytes / Math.pow(1024, exponent);
  return `${value.toFixed(value >= 10 ? 0 : 1)} ${units[exponent]}`;
}

function setMessageText(element, text) {
  element.textContent = text;
  if (text.includes('\n')) {
    element.innerHTML = element.innerHTML.replace(/\n/g, '<br />');
  }
}

function normaliseAttachments(list = []) {
  return list
    .filter((item) => item)
    .map((item) => {
      const numericSize = Number(item.size);
      const derivedSize = Number.isFinite(numericSize)
        ? numericSize
        : typeof item.length === 'number'
          ? item.length
          : 0;
      return {
        name: item.name || item.filename || 'Attachment',
        size: typeof item.size === 'number' ? item.size : derivedSize
      };
    });
}

function createMessage(role, text, options = {}) {
  const { attachments = [], isLoading = false, timestamp = new Date() } = options;
  const article = document.createElement('article');
  article.className = `message ${role} message--incoming`;
  if (isLoading) {
    article.classList.add('is-loading');
  }

  const avatar = document.createElement('div');
  avatar.className = 'avatar';
  if (role === 'ai') {
    const img = document.createElement('img');
    img.src = 'assets/Atlas_Logo.png';
    img.alt = 'Oji avatar';
    avatar.appendChild(img);
  } else {
    const span = document.createElement('span');
    span.textContent = 'You';
    avatar.appendChild(span);
  }

  const content = document.createElement('div');
  content.className = 'content';

  const meta = document.createElement('div');
  meta.className = 'meta';
  const author = document.createElement('span');
  author.className = 'author';
  author.textContent = role === 'ai' ? 'Oji' : 'You';
  const time = document.createElement('time');
  time.textContent = timestamp instanceof Date ? formatTime(timestamp) : timestamp;
  meta.append(author, time);

  const paragraph = document.createElement('p');
  if (isLoading) {
    const loader = document.createElement('div');
    loader.className = 'loader';
    loader.innerHTML = '<span></span><span></span><span></span>Oji is grabbing some binary coffee…';
    content.append(meta, loader);
  } else {
    setMessageText(paragraph, text);
    content.append(meta, paragraph);
  }

  const normalised = normaliseAttachments(attachments);
  if (normalised.length) {
    const list = document.createElement('ul');
    list.className = 'attachment-list';
    normalised.forEach((file) => {
      const item = document.createElement('li');
      item.className = 'attachment-item';
      const name = document.createElement('span');
      name.className = 'attachment-name';
      name.textContent = file.name;
      const size = document.createElement('span');
      size.className = 'attachment-size';
      size.textContent = formatFileSize(file.size);
      item.append(name, size);
      list.appendChild(item);
    });
    content.appendChild(list);
  }

  article.append(avatar, content);
  return article;
}

function showLoader() {
  const loader = createMessage('ai', '', { isLoading: true, timestamp: 'now' });
  loader.id = 'oji-loader';
  return loader;
}

function updateHistory(text) {
  if (!historyList) return;
  const label = text.trim();
  const safeLabel = label || 'File upload';
  const item = document.createElement('li');
  item.textContent = `${new Date().toLocaleDateString()} · ${safeLabel.slice(0, 42)}${safeLabel.length > 42 ? '…' : ''}`;
  historyList.prepend(item);
}

function toggleComposerDisabled(disabled) {
  if (messageInput) {
    messageInput.disabled = disabled;
    messageInput.setAttribute('aria-busy', String(disabled));
  }
  if (fileInput) {
    fileInput.disabled = disabled;
  }
  if (sendButton) {
    sendButton.disabled = disabled;
    sendButton.setAttribute('aria-disabled', String(disabled));
  }
  if (chatForm) {
    chatForm.classList.toggle('is-sending', disabled);
  }
}

function appendMessage(message) {
  chatWindow.appendChild(message);
  scrollToBottom();
}

async function handleSubmit(event) {
  event.preventDefault();
  if (isSending) {
    return;
  }

  if (!messageInput) {
    return;
  }

  if (!chatWindow) {
    return;
  }

  const text = messageInput.value.trim();
  const attachments = fileInput && fileInput.files ? Array.from(fileInput.files) : [];
  if (!text && attachments.length === 0) {
    return;
  }

  const payloadMessage = text || (attachments.length ? `Files uploaded: ${attachments.map((file) => file.name).join(', ')}` : '');
  const userDisplay = text || (attachments.length ? '[File upload]' : payloadMessage);
  const attachmentMeta = attachments.map((file) => ({ name: file.name, size: file.size }));

  const userMessage = createMessage('user', userDisplay, { attachments: attachmentMeta });
  appendMessage(userMessage);

  const loader = showLoader();
  appendMessage(loader);

  try {
    isSending = true;
    toggleComposerDisabled(true);
    const response = await sendMessage(payloadMessage, attachments);
    loader.remove();
    const reply = response.reply || response.data || response.message || 'Oji processed the request.';
    const aiAttachments = Array.isArray(response.files) ? normaliseAttachments(response.files) : [];
    const aiMessage = createMessage('ai', reply, { attachments: aiAttachments });
    appendMessage(aiMessage);
    inlineHeroicons(aiMessage);
    updateHistory(payloadMessage);
  } catch (error) {
    console.error('Chat submission failed', error);
    loader.remove();
    const errorMessage = createMessage('ai', `Something glitched in the surreal ether: ${error.message || 'Unknown error'}`);
    appendMessage(errorMessage);
  } finally {
    isSending = false;
    toggleComposerDisabled(false);
    if (fileInput) {
      fileInput.value = '';
    }
    messageInput.value = '';
    messageInput.focus();
    scrollToBottom();
  }
}

function handleQuickAction(event) {
  if (event.target.matches('[data-quick]')) {
    const action = event.target.dataset.quick;
    const templates = {
      'summarize': 'Can you summarize the current brief and highlight the warmth ratios? ',
      'next-steps': 'Outline the next three surreal steps for this project.',
      'log-memory': 'Log this note into long horizon memory: ',
      'share-update': 'Draft an update for the client emphasizing geometric surrealism.'
    };
    messageInput.value = templates[action] || '';
    messageInput.focus();
  }
}

function setupMemoryButton() {
  const memoryButton = document.querySelector('[data-action="open-memory"]');
  if (memoryButton) {
    memoryButton.addEventListener('click', () => openModal('memory-viewer'));
  }
}

document.addEventListener('components:ready', () => {
  chatWindow = document.getElementById('chat-window');
  chatForm = document.getElementById('chat-form');
  messageInput = document.getElementById('message-input');
  fileInput = document.getElementById('file-input');
  sendButton = chatForm ? chatForm.querySelector('.send-button') : null;
  quickActionContainer = document.getElementById('quick-actions');
  historyList = document.getElementById('history-list');

  if (chatForm) {
    chatForm.addEventListener('submit', handleSubmit);
  }
  if (quickActionContainer) {
    quickActionContainer.addEventListener('click', handleQuickAction);
  }

  setupMemoryButton();
});
