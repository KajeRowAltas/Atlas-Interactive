function setWarmth(value) {
  const warmAlpha = (value / 100) * 0.5;
  const coolAlpha = ((100 - value) / 100) * 0.45;
  document.documentElement.style.setProperty('--warmth-glow', warmAlpha.toFixed(2));
  document.documentElement.style.setProperty('--cool-glow', coolAlpha.toFixed(2));
  localStorage.setItem('oji-warmth', String(value));
}

document.addEventListener('components:ready', () => {
  const paletteSlider = document.getElementById('palette-balance');
  const notificationTone = document.getElementById('notification-tone');
  const shortcutField = document.getElementById('command-shortcut');

  const savedWarmth = Number(localStorage.getItem('oji-warmth'));
  if (paletteSlider && savedWarmth) {
    paletteSlider.value = savedWarmth;
    setWarmth(savedWarmth);
  }

  if (paletteSlider) {
    paletteSlider.addEventListener('input', (event) => {
      setWarmth(Number(event.target.value));
    });
  }

  if (notificationTone) {
    const savedTone = localStorage.getItem('oji-tone');
    if (savedTone) notificationTone.value = savedTone;
    notificationTone.addEventListener('change', () => {
      localStorage.setItem('oji-tone', notificationTone.value);
    });
  }

  document.querySelectorAll('[data-setting]').forEach((checkbox) => {
    const key = `oji-setting-${checkbox.dataset.setting}`;
    const stored = localStorage.getItem(key);
    if (stored !== null) {
      checkbox.checked = stored === 'true';
    }
    checkbox.addEventListener('change', () => {
      localStorage.setItem(key, checkbox.checked ? 'true' : 'false');
    });
  });

  if (shortcutField) {
    const savedShortcut = localStorage.getItem('oji-shortcut');
    if (savedShortcut) shortcutField.value = savedShortcut;
    shortcutField.addEventListener('input', () => {
      if (!shortcutField.value) return;
      localStorage.setItem('oji-shortcut', shortcutField.value.slice(0, 1));
    });
  }
});
