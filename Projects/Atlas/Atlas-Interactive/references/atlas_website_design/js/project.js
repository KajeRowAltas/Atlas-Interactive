import { openModal } from './app.js';

const projectMessages = {
  launch: 'Launching surreal kickoff flow. Remember to align with Broken Yellow beams.',
  harvest: 'Harvesting knowledge nodes. Map to Atlas memory field.',
  portal: 'Client portal canvas unlocked. Draft UI in warm geometric layers.',
  observatory: 'Analytics observatory queued. TODO: integrate metrics with memory DB.'
};

document.addEventListener('components:ready', () => {
  document.querySelectorAll('[data-project]').forEach((button) => {
    button.addEventListener('click', () => {
      const key = button.dataset.project;
      const message = projectMessages[key] || 'Project action recorded.';
      const memoryModal = document.getElementById('memory-viewer');
      if (memoryModal) {
        openModal('memory-viewer');
        const body = memoryModal.querySelector('.modal-body');
        if (body) {
          const note = document.createElement('p');
          note.textContent = message;
          body.prepend(note);
        }
      }
    });
  });
});
