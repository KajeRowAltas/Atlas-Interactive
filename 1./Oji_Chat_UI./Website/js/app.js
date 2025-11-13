const iconLibrary = {
  "chat-bubble-left": "M2.25 12c0 1.6.63 3.06 1.757 4.243A5.985 5.985 0 008 18h3.75L15 21.75V18h.75a4.5 4.5 0 004.5-4.5v-6a4.5 4.5 0 00-4.5-4.5h-9a4.5 4.5 0 00-4.5 4.5v6z",
  "chart-bar": "M3 19.5A1.5 1.5 0 004.5 21h15a1.5 1.5 0 001.5-1.5V6.75m-16.5 12V12a1.5 1.5 0 011.5-1.5h1.5A1.5 1.5 0 018 12v6m0 0v-9A1.5 1.5 0 019.5 7.5H11A1.5 1.5 0 0112.5 9v9m0 0V6A1.5 1.5 0 0114 4.5h1.5A1.5 1.5 0 0117 6v12m0 0v-6A1.5 1.5 0 0118.5 10.5H20A1.5 1.5 0 0121.5 12v7.5",
  "squares-2x2": "M3.75 5.25h6.5a1 1 0 011 1v6.5a1 1 0 01-1 1h-6.5a1 1 0 01-1-1v-6.5a1 1 0 011-1zm10 0h6.5a1 1 0 011 1v6.5a1 1 0 01-1 1h-6.5a1 1 0 01-1-1v-6.5a1 1 0 011-1zm-10 10h6.5a1 1 0 011 1v6.5a1 1 0 01-1 1h-6.5a1 1 0 01-1-1v-6.5a1 1 0 011-1zm10 0h6.5a1 1 0 011 1v6.5a1 1 0 01-1 1h-6.5a1 1 0 01-1-1v-6.5a1 1 0 011-1z",
  "adjustments-horizontal": "M3 6h11.25M3 12h7.5M3 18h11.25M17.25 6h3M13.5 12h6.75M17.25 18h3",
  "shield-check": "M9 12l2.25 2.25L15 10.5m6-2.25v6.75c0 2.96-1.59 5.7-4.17 7.17l-2.25 1.28a4.5 4.5 0 01-4.41 0l-2.25-1.28A8.25 8.25 0 013 15V8.25a2.25 2.25 0 011.17-1.98l7.5-4.2a2.25 2.25 0 012.16 0l7.5 4.2A2.25 2.25 0 0121 8.25z",
  "clock": "M12 6v6l3.75 3.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z",
  "brain": "M15.75 4.5a3 3 0 00-6 0v13.5a3 3 0 006 0V4.5zM6.75 5.25h.75a2.25 2.25 0 012.25 2.25v9a2.25 2.25 0 01-2.25 2.25h-.75A2.25 2.25 0 014.5 16.5V7.5a2.25 2.25 0 012.25-2.25zm10.5 0h-.75a2.25 2.25 0 00-2.25 2.25v9a2.25 2.25 0 002.25 2.25h.75A2.25 2.25 0 0021 16.5V7.5a2.25 2.25 0 00-2.25-2.25z",
  "sparkles": "M12 3v1.5M17.25 12l1.125.375M6.75 12L5.625 12.375M16.5 7.5L17.625 6.375M7.5 7.5L6.375 6.375M12 21v-1.5M4.5 12a7.5 7.5 0 0115 0 7.5 7.5 0 01-15 0z",
  "paper-clip": "M18.364 5.636a4.5 4.5 0 010 6.364l-7.071 7.07a4.5 4.5 0 11-6.364-6.364l7.07-7.07a3 3 0 114.243 4.243l-7.07 7.071a1.5 1.5 0 01-2.122-2.122l6.364-6.364",
  "paper-airplane": "M6.115 5.19a1.5 1.5 0 012.16-1.643l11.25 5.625a1.5 1.5 0 010 2.656l-11.25 5.625A1.5 1.5 0 015.25 16.125l1.395-3.25a1.5 1.5 0 011.383-.898h4.472",
  "x-mark": "M6 18L18 6M6 6l12 12"
};

const componentCache = new Map();

async function loadComponent(element) {
  const path = element.dataset.include;
  if (!path) return;
  if (componentCache.has(path)) {
    element.innerHTML = componentCache.get(path);
    return;
  }
  const response = await fetch(path);
  const html = await response.text();
  componentCache.set(path, html);
  element.innerHTML = html;
}

function inlineHeroicons(root = document) {
  const icons = root.querySelectorAll('[data-heroicon]');
  icons.forEach((icon) => {
    const name = icon.getAttribute('data-heroicon');
    const path = iconLibrary[name];
    if (!path) return;
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('viewBox', '0 0 24 24');
    svg.setAttribute('fill', 'none');
    svg.setAttribute('stroke-width', '1.5');
    svg.setAttribute('stroke', 'currentColor');
    const pathEl = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    pathEl.setAttribute('stroke-linecap', 'round');
    pathEl.setAttribute('stroke-linejoin', 'round');
    pathEl.setAttribute('d', path);
    svg.appendChild(pathEl);
    icon.replaceChildren(svg);
  });
}

function setActiveNav() {
  const current = location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.nav-links a').forEach((link) => {
    const href = link.getAttribute('href');
    if (href === current) {
      link.classList.add('active');
    } else {
      link.classList.remove('active');
    }
  });
}

function applyTheme() {
  const saved = localStorage.getItem('oji-theme') || 'light';
  if (saved === 'dark') {
    document.body.classList.add('dark');
  }
  const toggle = document.getElementById('dark-toggle');
  if (toggle) {
    toggle.classList.toggle('active', document.body.classList.contains('dark'));
    toggle.setAttribute('aria-checked', document.body.classList.contains('dark'));
  }
}

function toggleDarkMode() {
  document.body.classList.toggle('dark');
  const dark = document.body.classList.contains('dark') ? 'dark' : 'light';
  localStorage.setItem('oji-theme', dark);
  const toggle = document.getElementById('dark-toggle');
  if (toggle) {
    toggle.classList.toggle('active', dark === 'dark');
    toggle.setAttribute('aria-checked', dark === 'dark');
  }
}

function setupDarkToggle() {
  const toggle = document.getElementById('dark-toggle');
  if (!toggle) return;
  toggle.addEventListener('click', toggleDarkMode);
  toggle.addEventListener('keydown', (event) => {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      toggleDarkMode();
    }
  });
}

function bindModalTriggers() {
  document.querySelectorAll('[data-close]').forEach((button) => {
    button.addEventListener('click', () => closeModal(button.dataset.close));
  });
  const memoryBtn = document.getElementById('open-memory');
  if (memoryBtn) memoryBtn.addEventListener('click', () => openModal('memory-viewer'));
  const historyBtn = document.getElementById('open-history');
  if (historyBtn) historyBtn.addEventListener('click', () => openModal('chat-history'));
  document.querySelectorAll('.modal').forEach((modal) => {
    modal.addEventListener('click', (event) => {
      if (event.target === modal) {
        closeModal(modal.id);
      }
    });
  });
}

function applyStoredFeatures() {
  const bindings = {
    'quick-actions': '#quick-actions',
    'memory-viewer': '#memory-viewer',
    'chat-history': '#chat-history',
    'file-upload': '#file-input'
  };

  Object.entries(bindings).forEach(([key, selector]) => {
    const state = localStorage.getItem(`feature-${key}`);
    if (state === null) return;
    const element = document.querySelector(selector);
    if (!element) return;
    const enabled = state === 'true';
    element.classList.toggle('hidden', !enabled);
    if (selector === '#file-input') {
      const label = document.querySelector('label[for="file-input"]');
      if (label) label.classList.toggle('hidden', !enabled);
    }
    if (key === 'memory-viewer') {
      const button = document.getElementById('open-memory');
      if (button) button.classList.toggle('hidden', !enabled);
    }
    if (key === 'chat-history') {
      const button = document.getElementById('open-history');
      if (button) button.classList.toggle('hidden', !enabled);
    }
  });
}

function openModal(id) {
  const modal = document.getElementById(id);
  if (modal) {
    modal.classList.add('active');
  }
}

function closeModal(id) {
  const modal = document.getElementById(id);
  if (modal) {
    modal.classList.remove('active');
  }
}

function initCommandShortcut() {
  document.addEventListener('keydown', (event) => {
    const configured = localStorage.getItem('oji-shortcut') || '/';
    const isInput = event.target instanceof HTMLInputElement || event.target instanceof HTMLTextAreaElement;
    if (!isInput && event.key === configured) {
      event.preventDefault();
      document.dispatchEvent(new CustomEvent('command:toggle'));
    }
  });
}

function setCurrentYear() {
  const target = document.getElementById('current-year');
  if (target) {
    target.textContent = new Date().getFullYear().toString();
  }
}

async function init() {
  const includeTargets = Array.from(document.querySelectorAll('[data-include]'));
  await Promise.all(includeTargets.map((el) => loadComponent(el)));
  inlineHeroicons();
  applyTheme();
  setupDarkToggle();
  bindModalTriggers();
  applyStoredFeatures();
  setActiveNav();
  initCommandShortcut();
  setCurrentYear();
  document.dispatchEvent(new CustomEvent('components:ready'));
}

init();

export { inlineHeroicons, openModal, closeModal, toggleDarkMode };
