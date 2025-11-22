import { openModal } from './app.js';

const commandActions = {
  '/memory': () => openModal('memory-viewer'),
  '/history': () => openModal('chat-history'),
  '/dashboard': () => (window.location.href = 'dashboard.html'),
  '/projects': () => (window.location.href = 'project-panel.html'),
  '/settings': () => (window.location.href = 'settings.html')
};

let commandBar;
let commandItems;
let isVisible = false;
let selectedIndex = 0;

function activateCommand(index) {
  const item = commandItems[index];
  if (!item) return;
  const command = item.dataset.command;
  hideCommandBar();
  const handler = commandActions[command];
  if (handler) handler();
}

function highlightItem(index) {
  commandItems.forEach((item, i) => {
    item.classList.toggle('active', i === index);
  });
}

function showCommandBar() {
  if (!commandBar) return;
  if (!commandItems.length) return;
  commandBar.classList.add('active');
  isVisible = true;
  selectedIndex = 0;
  highlightItem(selectedIndex);
}

function hideCommandBar() {
  if (!commandBar) return;
  commandBar.classList.remove('active');
  isVisible = false;
}

function handleKeyNavigation(event) {
  if (!isVisible) return;
  if (!commandItems.length) {
    hideCommandBar();
    return;
  }
  if (event.key === 'ArrowDown') {
    event.preventDefault();
    selectedIndex = (selectedIndex + 1) % commandItems.length;
    highlightItem(selectedIndex);
  } else if (event.key === 'ArrowUp') {
    event.preventDefault();
    selectedIndex = (selectedIndex - 1 + commandItems.length) % commandItems.length;
    highlightItem(selectedIndex);
  } else if (event.key === 'Enter') {
    event.preventDefault();
    activateCommand(selectedIndex);
  } else if (event.key === 'Escape') {
    hideCommandBar();
  }
}

function setupCommands() {
  commandBar = document.getElementById('command-bar');
  if (!commandBar) return;
  commandItems = Array.from(commandBar.querySelectorAll('li'));
  commandItems.forEach((item, index) => {
    item.addEventListener('click', () => activateCommand(index));
  });

  document.addEventListener('keydown', handleKeyNavigation);

  document.addEventListener('command:toggle', () => {
    if (isVisible) {
      hideCommandBar();
    } else {
      showCommandBar();
    }
  });
}

document.addEventListener('components:ready', setupCommands);

export { showCommandBar, hideCommandBar };
