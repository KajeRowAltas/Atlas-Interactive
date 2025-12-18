import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/atlas_theme_data.dart';
import '../services/backend_service.dart';
import '../widgets/atlas_card.dart';
import '../widgets/atlas_status_chip.dart';

class OjiView extends StatefulWidget {
  const OjiView({super.key, required this.onCommand});

  final ValueChanged<String> onCommand;

  @override
  State<OjiView> createState() => _OjiViewState();
}

class _OjiViewState extends State<OjiView> {
  final BackendService _backend = BackendService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _actionLog = [];
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      author: 'Oji',
      content:
          'Link established. I am ready to orchestrate Atlas tasks or shift to Google Workspace when needed.',
      fromUser: false,
      timestamp: DateTime.now(),
    ),
    _ChatMessage(
      author: 'You',
      content:
          'Let us review the dashboard momentum and prep a summary for Google Drive.',
      fromUser: true,
      timestamp: DateTime.now(),
    ),
  ];
  bool _sending = false;

  void _addLog(String entry) {
    _actionLog.add("[${DateTime.now().toIso8601String()}] $entry");
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    _controller.clear();
    final message = _ChatMessage(
      author: 'You',
      content: text,
      fromUser: true,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();

    if (text.startsWith('/')) {
      if (text == '/logs') {
        _showLogs();
      } else {
        _addLog("Command sent: $text");
        widget.onCommand(text);
      }
    } else {
      _sendToBackend(text);
    }
  }

  Future<void> _sendToBackend(String text) async {
    setState(() {
      _sending = true;
    });
    _addLog("Sending chat to backend: \"$text\"");
    try {
      final reply = await _backend.sendChat(text);
      final snippet = reply.errorBody;
      final preview = snippet == null
          ? ''
          : snippet.substring(0, snippet.length > 120 ? 120 : snippet.length);
      _addLog("Response ${reply.statusCode} (ok=${reply.ok}) $preview");
      if (!reply.ok) {
        setState(() {
          _messages.add(
            _ChatMessage(
              author: 'Oji',
              content:
                  'Backend error ${reply.statusCode}: ${reply.errorBody ?? reply.message}',
              fromUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        return;
      }
      setState(() {
        _messages.add(
          _ChatMessage(
            author: 'Oji',
            content: reply.message,
            fromUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      _addLog("Error contacting backend: $e");
      setState(() {
        _messages.add(
          _ChatMessage(
            author: 'Oji',
            content: 'Error contacting backend: $e',
            fromUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } finally {
      setState(() {
        _sending = false;
      });
      _scrollToBottom();
    }
  }

  void _showLogs() {
    final logText =
        _actionLog.isEmpty ? 'No actions logged yet.' : _actionLog.join('\n');
    setState(() {
      _messages.add(
        _ChatMessage(
          author: 'Oji',
          content: logText,
          fromUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    // Wrap in SizedBox.expand so children get finite height and avoid unbounded flex errors.
    return SizedBox.expand(
      child: LayoutBuilder(builder: (context, constraints) {
        final bool wide = constraints.maxWidth > 1100;
        final sidePanel = SizedBox(
          width: wide ? 320 : double.infinity,
          child: Column(
            children: [
              AtlasCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Actions',
                        style: textTheme.titleLarge
                            ?.copyWith(color: scheme.onSurface)),
                    const SizedBox(height: 8),
                    Text(
                      'Reserved panel for orchestration. Oji can push quick replies, drafts, or workspace intents here.',
                      style: textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.72)),
                    ),
                    const SizedBox(height: 12),
                    const Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        AtlasStatusChip(label: 'Summary'),
                        AtlasStatusChip(
                            label: 'Route to Drive',
                            color: AtlasPalette.teal,
                            icon: Icons.folder),
                        AtlasStatusChip(
                            label: 'Schedule',
                            color: AtlasPalette.yellow,
                            icon: Icons.event),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    ...const [
                      _ActionTile(
                        title: 'Prep meeting notes',
                        detail:
                            'Draft agenda sourced from latest dashboard logs.',
                        icon: Icons.edit_note,
                      ),
                      _ActionTile(
                        title: 'Archive context',
                        detail: 'Store highlights to memory and Drive.',
                        icon: Icons.archive_outlined,
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AtlasCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Signal',
                        style: textTheme.titleMedium
                            ?.copyWith(color: scheme.onSurface)),
                    const SizedBox(height: 10),
                    const AtlasStatusChip(
                        label: 'Listening',
                        color: AtlasPalette.teal,
                        icon: Icons.hearing),
                    const SizedBox(height: 12),
                    Text(
                      'Oji keeps the palette ratio balanced and watches for AI-tool prompts.',
                      style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        final chatPanel = AtlasCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AtlasGradients.pill,
                      borderRadius: BorderRadius.circular(AtlasRadii.pill),
                      boxShadow: AtlasShadows.glow,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            color:
                                AtlasPalette.deepTeal.withValues(alpha: 0.92),
                            size: 18),
                        const SizedBox(width: 6),
                        Text('Oji',
                            style: textTheme.labelLarge
                                ?.copyWith(color: AtlasPalette.deepTeal)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Conversational interface for Atlas.',
                    style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7)),
                  ),
                  const Spacer(),
                  const AtlasStatusChip(
                      label: 'Live', color: AtlasPalette.teal),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 18),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _MessageBubble(message: message);
                  },
                ),
              ),
              const SizedBox(height: 10),
              _ChatComposer(
                controller: _controller,
                onSend: _send,
                sending: _sending,
              ),
            ],
          ),
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: chatPanel),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: sidePanel),
            ],
          );
        }

        return Column(
          children: [
            chatPanel,
            const SizedBox(height: 14),
            sidePanel,
          ],
        );
      }),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer(
      {required this.controller, required this.onSend, required this.sending});

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AtlasRadii.md),
        border: Border.all(
            color:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(
                hintText: 'Message or command (start with /)',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: sending ? null : onSend,
            child: Text(
              sending ? 'Sending...' : 'Send',
              style: textTheme.labelLarge?.copyWith(color: AtlasPalette.beige),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isUser = message.fromUser;
    final bubbleColor = isUser
        ? scheme.primaryContainer.withValues(alpha: 0.75)
        : scheme.surface.withValues(alpha: 0.9);
    final borderColor =
        isUser ? scheme.primary.withValues(alpha: 0.35) : scheme.outline;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(26),
      topRight: const Radius.circular(26),
      bottomLeft: Radius.circular(isUser ? 20 : 12),
      bottomRight: Radius.circular(isUser ? 12 : 20),
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            const _Avatar(
              initials: 'OJI',
              gradient: LinearGradient(colors: [
                Color.fromRGBO(31, 95, 91, 0.75),
                Color.fromRGBO(31, 95, 91, 0.35)
              ]),
              imageAsset: 'assets/images/Oji_Logo.png',
            ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: radius,
                border: Border.all(color: borderColor),
                boxShadow: const [
                  BoxShadow(
                      color: Color.fromRGBO(19, 55, 53, 0.18),
                      blurRadius: 18,
                      offset: Offset(0, 12)),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: AtlasSurfaces.grain(opacity: 0.22)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              message.author.toUpperCase(),
                              style: textTheme.labelMedium?.copyWith(
                                color: isUser
                                    ? scheme.onPrimaryContainer
                                    : scheme.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatTime(message.timestamp),
                              style: textTheme.labelMedium?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          message.content,
                          style: textTheme.bodyLarge
                              ?.copyWith(color: scheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser)
            const _Avatar(
              initials: 'YOU',
              gradient: LinearGradient(colors: [
                Color.fromRGBO(233, 164, 48, 0.9),
                Color.fromRGBO(201, 76, 29, 0.55)
              ]),
              imageAsset: 'assets/images/Kaje_Logo.png',
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar(
      {required this.initials, required this.gradient, this.imageAsset});

  final String initials;
  final Gradient gradient;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(19, 55, 53, 0.4),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AtlasPalette.beige.withValues(alpha: 0.25),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageAsset != null
          ? Image.asset(
              imageAsset!,
              fit: BoxFit.cover,
            )
          : Center(
              child: Text(
                initials,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AtlasPalette.beige,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.title, required this.detail, required this.icon});

  final String title;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: scheme.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        textTheme.bodyLarge?.copyWith(color: scheme.onSurface)),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: scheme.onSurface.withValues(alpha: 0.4)),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.author,
    required this.content,
    required this.fromUser,
    required this.timestamp,
  });

  final String author;
  final String content;
  final bool fromUser;
  final DateTime timestamp;
}
