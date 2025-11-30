import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const AtlasApp());
}

/// CommandController implements the Dual-Control pattern.
/// - Use navigateTo(index) or navigateToName("terminal") to programmatically change tabs.
/// - Add commands to the controller via addCommand(String) if you want MainShell to process textual commands,
///   because MainShell listens to controller.commandStream and will call executeCommand on incoming commands.
class CommandController {
  /// ValueNotifier for the selected index. UI listens to this.
  final ValueNotifier<int> indexNotifier;

  /// Broadcast stream for textual commands (from AI or other systems).
  final StreamController<String> _commandStream = StreamController<String>.broadcast();

  CommandController({int initialIndex = 0}) : indexNotifier = ValueNotifier<int>(initialIndex);

  Stream<String> get commandStream => _commandStream.stream;

  int get index => indexNotifier.value;

  void navigateTo(int index) {
    if (index < 0) return;
    indexNotifier.value = index;
  }

  void navigateToName(String name) {
    switch (name.toLowerCase()) {
      case 'oracle':
      case 'chat':
      case 'ai':
        navigateTo(0);
        break;
      case 'terminal':
      case 'logs':
        navigateTo(1);
        break;
      case 'dashboard':
      case 'workspace':
      case 'shared':
      case 'drive':
        navigateTo(2);
        break;
      case 'markets':
      case 'crypto':
      case 'tradingview':
        navigateTo(3);
        break;
      default:
        // try parse as numeric index
        final idx = int.tryParse(name);
        if (idx != null && idx >= 0 && idx <= 3) {
          navigateTo(idx);
        }
        break;
    }
  }

  /// External systems can push textual commands here.
  void addCommand(String command) {
    _commandStream.add(command);
  }

  void dispose() {
    indexNotifier.dispose();
    _commandStream.close();
  }
}

class AtlasApp extends StatefulWidget {
  const AtlasApp({Key? key}) : super(key: key);

  @override
  State<AtlasApp> createState() => _AtlasAppState();
}

class _AtlasAppState extends State<AtlasApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark as required.
  final CommandController _commandController = CommandController(initialIndex: 0);

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  void _toggleThemeMode(bool toDark) {
    setState(() {
      _themeMode = toDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan, brightness: Brightness.light),
      useMaterial3: false,
    );

    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF071018),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan, brightness: Brightness.dark),
      textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      useMaterial3: false,
    );

    return MaterialApp(
      title: 'ATLAS',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: MainShell(
        commandController: _commandController,
        themeMode: _themeMode,
        onThemeModeChanged: (newMode) => _toggleThemeMode(newMode == ThemeMode.dark),
        // We keep the App title and brand up top inside the shell UI.
      ),
    );
  }
}

/// MainShell: The main shell architecture with a persistent NavigationRail and IndexedStack.
class MainShell extends StatefulWidget {
  final CommandController commandController;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const MainShell({
    Key? key,
    required this.commandController,
    required this.themeMode,
    required this.onThemeModeChanged,
  }) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _selectedIndex;
  StreamSubscription<String>? _commandSub;
  // For chat -> we will call executeCommand for commands starting with '/'
  // Command parsing is handled here.
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.commandController.index;
    // When the controller index changes (programmatic navigation), update UI
    widget.commandController.indexNotifier.addListener(_onControllerIndexChanged);

    // Listen for textual commands pushed into the controller by AI/other systems
    _commandSub = widget.commandController.commandStream.listen((command) {
      executeCommand(command);
    });
  }

  void _onControllerIndexChanged() {
    final newIndex = widget.commandController.index;
    if (mounted && newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  @override
  void dispose() {
    widget.commandController.indexNotifier.removeListener(_onControllerIndexChanged);
    _commandSub?.cancel();
    super.dispose();
  }

  /// The required executeCommand(String) function inside MainShell state.
  /// Supports:
  ///  - /nav [page]  -> page names: oracle, terminal, dashboard, markets OR numeric index 0..3
  ///  - /panic -> shows a red snackbar (placeholder for API call)
  /// Unknown commands show an informational snackbar.
  void executeCommand(String command) {
    final cmd = command.trim();
    if (cmd.isEmpty) return;
    if (cmd.startsWith('/nav')) {
      // Examples:
      // /nav terminal
      // /nav 1
      final parts = cmd.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        final target = parts.sublist(1).join(' ').trim();
        // Support numeric
        final idx = int.tryParse(target);
        if (idx != null) {
          if (idx >= 0 && idx <= 3) {
            widget.commandController.navigateTo(idx);
            _showSnack('Navigating to index $idx');
          } else {
            _showSnack('Index out of range (0..3)', color: Colors.orange);
          }
          return;
        }
        // Try named pages
        switch (target.toLowerCase()) {
          case 'oracle':
          case 'chat':
          case 'ai':
            widget.commandController.navigateTo(0);
            _showSnack('Navigating to Oracle (Chat)');
            break;
          case 'terminal':
          case 'logs':
            widget.commandController.navigateTo(1);
            _showSnack('Navigating to Terminal (Logs)');
            break;
          case 'dashboard':
          case 'workspace':
          case 'shared':
          case 'drive':
            widget.commandController.navigateTo(2);
            _showSnack('Navigating to Dashboard (Shared Drive)');
            break;
          case 'markets':
          case 'crypto':
            widget.commandController.navigateTo(3);
            _showSnack('Navigating to Markets');
            break;
          default:
            _showSnack('Unknown navigation target: $target', color: Colors.orange);
            break;
        }
      } else {
        _showSnack('Usage: /nav [oracle|terminal|dashboard|markets|0..3]');
      }
    } else if (cmd == '/panic') {
      // Placeholder for API call — show red snackbar warning.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PANIC: Emergency triggered'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    } else {
      // Unknown command, treat as chat input or show info
      _showSnack('Unknown command: $cmd', color: Colors.grey);
    }
  }

  void _showSnack(String message, {Color color = Colors.blueGrey}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      body: Row(
        children: [
          // Left: NavigationRail (shell)
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              // Use the CommandController as the single source of truth for navigation.
              widget.commandController.navigateTo(index);
            },
            leading: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                children: [
                  // Atlas logo and title
                  GestureDetector(
                    onTap: () {
                      // Tap logo to go home/oracle.
                      widget.commandController.navigateTo(0);
                    },
                    child: Column(
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 8),
                        const Text(
                          'ATLAS',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dark mode toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDark ? Icons.nights_stay : Icons.wb_sunny,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Switch(
                      value: isDark,
                      onChanged: (v) {
                        widget.onThemeModeChanged(v ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Small help / command demo
                IconButton(
                  tooltip: 'Send sample /panic command',
                  onPressed: () {
                    // Demonstrate the dual-control: push a textual command into controller,
                    // MainShell is already subscribed and will execute it.
                    widget.commandController.addCommand('/panic');
                  },
                  icon: const Icon(Icons.flash_on_outlined),
                ),
                const SizedBox(height: 8),
              ],
            ),
            // Destinations (EXACTLY 4)
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.smart_toy_outlined),
                selectedIcon: Icon(Icons.smart_toy),
                label: Text('ORACLE'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.terminal_outlined),
                selectedIcon: Icon(Icons.terminal),
                label: Text('TERMINAL'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.folder_shared_outlined),
                selectedIcon: Icon(Icons.folder_shared),
                label: Text('DASHBOARD'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.show_chart_outlined),
                selectedIcon: Icon(Icons.show_chart),
                label: Text('MARKETS'),
              ),
            ],
          ),

          // Right: content area
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                // Index 0: ORACLE (Chat)
                OracleChat(
                  onExecuteCommand: (cmd) => executeCommand(cmd),
                ),

                // Index 1: TERMINAL (Bot Logs)
                const TerminalPane(),

                // Index 2: DASHBOARD (Shared Drive workspace) -- CRITICAL: only dashboard tab
                const DashboardPane(),

                // Index 3: MARKETS (TradingView placeholder)
                const MarketsPane(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    // load assets/images/Atlas_Logo.png. If missing, fallback to a shaped icon.
    return SizedBox(
      width: 56,
      height: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/Atlas_Logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.cyan,
              child: const Icon(
                Icons.language,
                color: Colors.black87,
                size: 32,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ORACLE: A simple chat placeholder. If a message starts with '/', it is treated as a command
/// and will call onExecuteCommand to allow the shell to process it.
class OracleChat extends StatefulWidget {
  final ValueChanged<String> onExecuteCommand;
  const OracleChat({Key? key, required this.onExecuteCommand}) : super(key: key);

  @override
  State<OracleChat> createState() => _OracleChatState();
}

class _OracleChatState extends State<OracleChat> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, fromUser: true));
    });
    _controller.clear();
    // If it's a command (starts with '/'), send to shell for execution
    if (text.startsWith('/')) {
      widget.onExecuteCommand(text);
      // Optionally echo command result as a system message; for now, placeholder:
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _messages.add(_ChatMessage(text: 'Executed command: "$text"', fromUser: false));
        });
        _scrollToBottom();
      });
    } else {
      // Simulate AI response
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          _messages.add(_ChatMessage(text: 'AI reply to: "$text"', fromUser: false));
        });
        _scrollToBottom();
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.03),
          child: Row(
            children: [
              const Text(
                'ORACLE',
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.3),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Talk to the AI — type /nav terminal or /panic',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, idx) {
              final m = _messages[idx];
              return Align(
                alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: m.fromUser
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.18)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    m.text,
                    style: TextStyle(
                      fontFamily: m.fromUser ? null : 'Roboto',
                      color: m.fromUser ? Theme.of(context).colorScheme.onPrimary : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Input area
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.02),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Message or command (start with /)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _send,
                  child: const Text('Send'),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatMessage {
  final String text;
  final bool fromUser;
  _ChatMessage({required this.text, required this.fromUser});
}

/// TERMINAL pane - black background, green Courier font (Matrix style).
class TerminalPane extends StatelessWidget {
  const TerminalPane({Key? key}) : super(key: key);

  static const List<String> sampleLogs = [
    '[vps] 2025-11-27 10:02:12 INFO Bot started',
    '[vps] 2025-11-27 10:02:13 DEBUG Strategy loaded: atr_retracement',
    '[vps] 2025-11-27 10:02:15 INFO Connected to exchange (prod)',
    '[vps] 2025-11-27 10:02:16 WARN Latency spike: 312ms',
    '[vps] 2025-11-27 10:02:18 INFO Order executed: BUY BTCUSD 0.002 @ 48200',
    '[vps] 2025-11-27 10:02:20 INFO Net PnL updated: +0.7%',
    '[vps] 2025-11-27 10:02:30 DEBUG Rebalance cycle complete',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TERMINAL',
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                sampleLogs.join('\n\n'),
                style: const TextStyle(
                  color: Color(0xFF00FF6A),
                  fontFamily: 'Courier',
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// DASHBOARD: Only dashboard workspace (Shared Drive theme as background).
/// - Use assets/images/Shared_Drive_Theme.png as BoxFit.cover
/// - Place a semi-transparent dark container (Colors.black54) over the image but under the text/buttons.
class DashboardPane extends StatelessWidget {
  const DashboardPane({Key? key}) : super(key: key);

  static const List<_StatusCardData> _cards = [
    _StatusCardData('Bot Status', 'Active', Icons.play_circle_outline, Colors.green),
    _StatusCardData('Net PnL', '+4%', Icons.pie_chart_outline, Colors.cyanAccent),
    _StatusCardData('Last Trade', 'BUY 0.002 BTC', Icons.swap_vertical_circle_outlined, Colors.orange),
    _StatusCardData('VPS Uptime', '3d 15h', Icons.cloud_done_outlined, Colors.teal),
    _StatusCardData('Open Bots', '4', Icons.devices_other_outlined, Colors.purpleAccent),
    _StatusCardData('Alerts', '1 Critical', Icons.notifications_active_outlined, Colors.redAccent),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/images/Shared_Drive_Theme.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, st) {
              return Container(color: Colors.grey.shade900);
            },
          ),
        ),

        // Semi-transparent overlay under the UI to ensure readability
        Positioned.fill(
          child: Container(
            color: Colors.black54,
          ),
        ),

        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DASHBOARD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Shared Drive Workspace',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 18),
                // Grid of status cards
                Expanded(
                  child: GridView.builder(
                    itemCount: _cards.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.8,
                    ),
                    itemBuilder: (context, index) {
                      final c = _cards[index];
                      return _StatusCard(data: c);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  const _StatusCardData(this.title, this.value, this.icon, this.accent);
}

class _StatusCard extends StatelessWidget {
  final _StatusCardData data;
  const _StatusCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.06),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          // Placeholder: show details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${data.title}: ${data.value}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: data.accent.withValues(alpha: 0.12),
                  child: Icon(data.icon, color: data.accent),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.value,
                      style: TextStyle(color: data.accent, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}

/// MARKETS pane - placeholder for WebView (TradingView)
class MarketsPane extends StatelessWidget {
  const MarketsPane({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For a real app you'd use a WebView widget or platform-specific implementation.
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 72, color: Colors.cyanAccent),
              SizedBox(height: 12),
              Text(
              'MARKETS',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('TradingView WebView placeholder'),
          ],
        ),
      ),
    );
  }
}
