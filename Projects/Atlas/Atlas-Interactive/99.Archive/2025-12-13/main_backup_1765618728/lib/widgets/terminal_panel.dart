import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';

import '../theme/atlas_theme_data.dart';
import 'atlas_card.dart';

class TerminalPanel extends StatefulWidget {
  const TerminalPanel({super.key});

  @override
  State<TerminalPanel> createState() => _TerminalPanelState();
}

class _TerminalPanelState extends State<TerminalPanel> {
  late final Pty _pty;
  late final Terminal _terminal;

  @override
  void initState() {
    super.initState();

    // 1. Start de shell
    _pty = Pty.start(
      '/bin/zsh',
      columns: 80,
      rows: 30,
    );

    // 2. Maak de terminal (xterm 4.0 style)
    _terminal = Terminal(
      maxLines: 10000,
    );

    // 3. Verbind OUTPUT (Systeem -> Scherm)
    _pty.output
        .cast<List<int>>()
        .transform(const Utf8Decoder())
        .listen(_terminal.write);

    // 4. Verbind INPUT (Toetsenbord -> Systeem)
    // In xterm 4.0 luisteren we via onOutput op de terminal zelf
    _terminal.onOutput = (data) {
      _pty.write(const Utf8Encoder().convert(data));
    };

    // 5. Welkomstbericht
    _terminal.write('Atlas Command Link Established.\r\n');
    _terminal.write('System: macOS (M1 Optimized)\r\n\n\$ ');
  }

  @override
  void dispose() {
    _pty.kill();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    return AtlasCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient:
                      AtlasGradients.pill, // Mirrors .icon-button gradient
                  borderRadius: BorderRadius.circular(AtlasRadii.pill),
                  boxShadow: AtlasShadows.glow,
                ),
                child: const Icon(
                  Icons.terminal,
                  color: AtlasPalette.deepTeal,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "COMMAND TERMINAL",
                style: textTheme.labelLarge?.copyWith(
                  letterSpacing: 3.2,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AtlasGradients.terminalChrome,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? AtlasPalette.beige.withValues(alpha: 0.12)
                      : scheme.outline,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(19, 55, 53, 0.25),
                    blurRadius: 22,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TerminalView(
                  _terminal,
                  textStyle: const TerminalStyle(
                    fontSize: 14,
                    fontFamily: 'Courier',
                  ),
                  backgroundOpacity: 0.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
