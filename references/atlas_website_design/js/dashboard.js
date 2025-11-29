import { openModal } from './app.js';

function notify(message) {
  const toast = document.createElement('div');
  toast.className = 'card';
  toast.style.position = 'fixed';
  toast.style.bottom = '32px';
  toast.style.right = '32px';
  toast.style.maxWidth = '320px';
  toast.innerHTML = `<h3>Dashboard Notice</h3><p>${message}</p>`;
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), 3200);
}

document.addEventListener('components:ready', () => {
  document.querySelectorAll('[data-action="view-velocity"]').forEach((button) => {
    button.addEventListener('click', () => notify('Velocity trending warm · keep the cadence.'));
  });

  document.querySelectorAll('[data-action="open-memory"]').forEach((button) => {
    button.addEventListener('click', () => openModal('memory-viewer'));
  });

  document.querySelectorAll('[data-action="adjust-palette"]').forEach((button) => {
    button.addEventListener('click', () => notify('Palette controls live inside settings. Adjust warmth to 70/30.'));
  });
});
