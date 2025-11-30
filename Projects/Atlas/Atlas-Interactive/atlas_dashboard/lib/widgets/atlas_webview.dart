import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/atlas_style.dart';
import 'atlas_card.dart';

class AtlasWebView extends StatefulWidget {
  const AtlasWebView({
    super.key,
    required this.title,
    required this.initialUrl,
    this.actions,
  });

  final String title;
  final String initialUrl;
  final List<Widget>? actions;

  @override
  State<AtlasWebView> createState() => _AtlasWebViewState();
}

class _AtlasWebViewState extends State<AtlasWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  void _reload() {
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.title.toUpperCase(),
                style: AtlasText.headingStyle(
                  size: 22,
                  color: AtlasColors.yellow,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Reload',
                onPressed: _reload,
                icon: const Icon(Icons.refresh, color: AtlasColors.beige),
              ),
              ...?widget.actions,
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: WebViewWidget(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }
}
