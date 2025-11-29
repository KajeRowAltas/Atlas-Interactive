# Oji – Atlas Interactive Chat Interface

Atlas Geometric Surrealism inspired web interface for the Atlas–Oji personal chatbot.

## Project Structure

```
Website/
├── index.html            # Chat interface
├── login.html            # Entry portal
├── dashboard.html        # Operational insights
├── settings.html         # Configuration controls
├── project-panel.html    # Project orchestration hub
├── admin.html            # Feature toggles & ops tools
├── css/
│   ├── styles.css        # Light theme & base design
│   └── dark.css          # Dark theme overrides
├── js/
│   ├── app.js            # Component loader & theming
│   ├── chat.js           # Chat UI interactions
│   ├── api.js            # n8n webhook integration
│   ├── commands.js       # Command palette logic
│   ├── dashboard.js      # Dashboard helpers
│   ├── settings.js       # Settings persistence
│   ├── project.js        # Project panel interactions
│   └── admin.js          # Admin panel controls
├── components/           # HTML partials
├── assets/               # Branding assets
│   └── textures/grain.png
└── README.md
```

## Local Development

1. Clone the repository and navigate to `Projects/Atlas/ui/oji_chat_ui/Website`.
2. Serve the directory with any static server:
   ```bash
   python -m http.server 8080
   ```
3. Visit `http://localhost:8080/index.html` in your browser.
4. All scripts are ES modules; ensure the server supports static module loading (Python HTTP server works).

## Dark Mode & Palette

- Dark mode is toggled from the sidebar switch and stored in `localStorage` (`oji-theme`).
- Palette warmth slider (Settings) controls CSS custom properties (`--warmth-glow`, `--cool-glow`).

## n8n Webhook Integration

- API requests are sent to `https://n8n.srv1094917.hstgr.cloud/webhook-test/Oji` via POST.
- To modify the endpoint, update `N8N_ENDPOINT` in `js/api.js`.
- Session identifiers are generated in `js/api.js#getSessionId` and persisted to `localStorage` (`oji-session-id`).
- The webhook payload now conforms to OjiDB expectations:
  ```json
  {
    "session_id": "session-1700000000000-deadbeef",
    "message": "Current prompt text",
    "timestamp": "2024-05-01T12:34:56.789Z",
    "speaker": "user",
    "project_id": null,
    "tags": ["brief", "surreal"],
    "files": [
      {
        "name": "moodboard.png",
        "url": "data:image/png;base64,iVBOR...",
        "type": "image/png",
        "size": 102400,
        "description": ""
      }
    ]
  }
  ```
- Each file is converted to a Data URL for the `url` field while retaining metadata (`name`, `type`, `size`). When no files are attached, an empty array is sent.
- Optional `project_id` and `tags` can be provided through the third argument of `sendMessage` (see `js/api.js`).

## Hostinger Deployment

1. Zip the contents of `Projects/Atlas/ui/oji_chat_ui/Website` or sync via Git.
2. Upload to Hostinger’s `public_html` (or configured subdirectory) using the file manager or FTP.
3. Ensure `index.html` is set as the default document.
4. Confirm `assets/`, `css/`, `js/`, and `components/` folders preserve structure.

## GitHub Integration Workflow

1. Push the project to GitHub.
2. In Hostinger, open **Git** integration and provide the repository URL.
3. Set the deployment directory to `Projects/Atlas/ui/oji_chat_ui/Website`.
4. Trigger manual deploy or enable automatic deployment on push.

## Future Enhancements (TODO)

- Integrate Trello automation endpoints for TODO syncing.
- Connect memory database for persistent AI recall.
- Add analytics observatory dashboards and telemetry.
- Harden authentication and connect to live identity provider.

## License

Proprietary © Kaje David Row – Atlas Interactive.
