import { sendMessage } from './api.js';
import { inlineHeroicons, openModal } from './app.js';

let chatWindow;
let chatForm;
let messageInput;
let fileInput;
let quickActionContainer;
let historyList;

function scrollToBottom() {
  if (chatWindow) {
    chatWindow.scrollTo({ top: chatWindow.scrollHeight, behavior: 'smooth' });
  }
}

function createMessage(role, text) {
  const article = document.createElement('article');
  article.className = `message ${role} message--incoming`;

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
  time.textContent = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  meta.append(author, time);

  const paragraph = document.createElement('p');
  paragraph.textContent = text;

  content.append(meta, paragraph);
  article.append(avatar, content);
  return article;
}

function showLoader() {
  const message = document.createElement('article');
  message.className = 'message ai message--incoming is-loading';
  message.id = 'oji-loader';
  const avatar = document.createElement('div');
  avatar.className = 'avatar';
  const img = document.createElement('img');
  img.src = 'assets/Atlas_Logo.png';
  img.alt = 'Oji avatar';
  avatar.appendChild(img);

  const content = document.createElement('div');
  content.className = 'content';
  const meta = document.createElement('div');
  meta.className = 'meta';
  const author = document.createElement('span');
  author.className = 'author';
  author.textContent = 'Oji';
  const time = document.createElement('time');
  time.textContent = 'now';
  meta.append(author, time);
  const loader = document.createElement('div');
  loader.className = 'loader';
  loader.innerHTML = '<span></span><span></span><span></span>Oji is grabbing some binary coffee…';
  content.append(meta, loader);
  message.append(avatar, content);
  return message;
}

function updateHistory(text) {
  if (!historyList) return;
  const item = document.createElement('li');
  item.textContent = `${new Date().toLocaleDateString()} · ${text.slice(0, 42)}${text.length > 42 ? '…' : ''}`;
  historyList.prepend(item);
}

async function handleSubmit(event) {
  event.preventDefault();
  const text = messageInput.value.trim();
  if (!text && (!fileInput || !fileInput.files.length)) {
    return;
  }

  const userMessage = createMessage('user', text || '[File upload]');
  chatWindow.appendChild(userMessage);
  scrollToBottom();

  const loader = showLoader();
  chatWindow.appendChild(loader);
  scrollToBottom();

  try {
    const response = await sendMessage(text, fileInput ? fileInput.files : []);
    loader.remove();
    const reply = response.reply || response.data || 'Oji processed the request.';
    const aiMessage = createMessage('ai', reply);
    chatWindow.appendChild(aiMessage);
    inlineHeroicons(aiMessage);
    updateHistory(text || 'File upload');
  } catch (error) {
    loader.remove();
    const errorMessage = createMessage('ai', `Something glitched in the surreal ether: ${error.message}`);
    chatWindow.appendChild(errorMessage);
  }

  if (fileInput) fileInput.value = '';
  messageInput.value = '';
  scrollToBottom();
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
