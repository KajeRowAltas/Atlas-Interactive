import 'dart:async';

import 'package:flutter/material.dart';

import 'theme/atlas_theme_data.dart';
import 'views/crypto_view.dart';
import 'views/dashboard_view.dart';
import 'views/google_workspace_view.dart';
import 'views/oji_view.dart';
import 'views/terminal_view.dart';

void main() {
  runApp(const AtlasApp());
}

/// CommandController implements the Dual-Control pattern.
/// - Use navigateTo(index) or navigateToName("google workspace") to programmatically change tabs.
/// - Add commands to the controller via addCommand(String) if you want MainShell to process textual commands,
///   because MainShell listens to controller.commandStream and will call executeCommand on incoming commands.
class CommandController {
  /// ValueNotifier for the selected index. UI listens to this.
  final ValueNotifier<int> indexNotifier;

  /// Broadcast stream for textual commands (from AI or other systems).
  final StreamController<String> _commandStream =
      StreamController<String>.broadcast();

  CommandController({int initialIndex = 0})
      : indexNotifier = ValueNotifier<int>(initialIndex);

  Stream<String> get commandStream => _commandStream.stream;

  int get index => indexNotifier.value;

  void navigateTo(int index) {
    if (index < 0 || index > 4) return;
    indexNotifier.value = index;
  }

  void navigateToName(String name) {
    switch (name.toLowerCase()) {
      case 'dashboard':
      case 'home':
      case 'workspace':
        navigateTo(0);
        break;
      case 'oji':
      case 'chat':
      case 'oracle':
        navigateTo(1);
        break;
      case 'crypto':
      case 'markets':
      case 'trading':
        navigateTo(2);
        break;
      case 'google workspace':
      case 'google':
      case 'drive':
      case 'gmail':
        navigateTo(3);
        break;
      case 'terminal':
      case 'logs':
        navigateTo(4);
        break;
      default:
        final idx = int.tryParse(name);
        if (idx != null && idx >= 0 && idx <= 4) {
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
  final CommandController _commandController =
      CommandController(initialIndex: 1); // Start on chat

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
    return MaterialApp(
      title: 'Atlas Interactive',
      debugShowCheckedModeBanner: false,
      theme: AtlasTheme.light(),
      darkTheme: AtlasTheme.dark(),
      themeMode: _themeMode,
      color: AtlasPalette.midnightTeal, // Window background color on macOS
      home: MainShell(
        commandController: _commandController,
        themeMode: _themeMode,
        onThemeModeChanged: (newMode) =>
            _toggleThemeMode(newMode == ThemeMode.dark),
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

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.commandController.index;
    widget.commandController.indexNotifier
        .addListener(_onControllerIndexChanged);

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
    widget.commandController.indexNotifier
        .removeListener(_onControllerIndexChanged);
    _commandSub?.cancel();
    super.dispose();
  }

  /// Supports:
  ///  - /nav [page]  -> page names: dashboard, oji, crypto, google workspace, terminal OR numeric index 0..4
  ///  - /panic -> shows a red snackbar (placeholder for API call)
  /// Unknown commands show an informational snackbar.
  void executeCommand(String command) {
    final cmd = command.trim();
    if (cmd.isEmpty) return;
    if (cmd.startsWith('/nav')) {
      final parts =
          cmd.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        final target = parts.sublist(1).join(' ').trim();
        final idx = int.tryParse(target);
        if (idx != null) {
          if (idx >= 0 && idx <= 4) {
            widget.commandController.navigateTo(idx);
            _showSnack('Navigating to index $idx');
          } else {
            _showSnack('Index out of range (0..4)', color: Colors.orange);
          }
          return;
        }
        switch (target.toLowerCase()) {
          case 'dashboard':
          case 'home':
            widget.commandController.navigateTo(0);
            _showSnack('Navigating to Dashboard');
            break;
          case 'oji':
          case 'chat':
          case 'oracle':
            widget.commandController.navigateTo(1);
            _showSnack('Navigating to Oji');
            break;
          case 'crypto':
          case 'markets':
            widget.commandController.navigateTo(2);
            _showSnack('Navigating to Crypto');
            break;
          case 'google workspace':
          case 'google':
          case 'drive':
            widget.commandController.navigateTo(3);
            _showSnack('Navigating to Google Workspace');
            break;
          case 'terminal':
          case 'logs':
            widget.commandController.navigateTo(4);
            _showSnack('Navigating to Terminal');
            break;
          default:
            _showSnack('Unknown navigation target: $target',
                color: Colors.orange);
            break;
        }
      } else {
        _showSnack(
            'Usage: /nav [dashboard|oji|crypto|google workspace|terminal|0..4]');
      }
    } else if (cmd == '/panic') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PANIC: Emergency triggered'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    } else {
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String tabLabel = _tabTitle(_selectedIndex);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AtlasGradients.appBackdrop : AtlasGradients.appWash,
        ),
        child: Stack(
          children: [
            Positioned.fill(
                child: AtlasSurfaces.grain(opacity: isDark ? 0.18 : 0.34)),
            Row(
              children: [
                _buildSidebar(isDark),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                    child: Container(
                      decoration: AtlasSurfaces.shell(isDark),
                      child: Stack(
                        children: [
                          Positioned.fill(
                              child: AtlasSurfaces.grain(
                                  opacity: isDark ? 0.12 : 0.2)),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      tabLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: scheme.onSurface,
                                            letterSpacing: 2.4,
                                          ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      tooltip: 'Send sample /panic command',
                                      onPressed: () => widget.commandController
                                          .addCommand('/panic'),
                                      icon: Icon(Icons.flash_on_outlined,
                                          color: scheme.secondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Expanded(
                                  child: IndexedStack(
                                    index: _selectedIndex,
                                    children: [
                                      const DashboardView(),
                                      OjiView(onCommand: executeCommand),
                                      const CryptoView(),
                                      const GoogleWorkspaceView(),
                                      const TerminalView(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(bool isDark) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: 288,
      margin: const EdgeInsets.fromLTRB(16, 16, 8, 16),
      decoration: BoxDecoration(
        gradient: AtlasGradients.sidebar,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AtlasPalette.beige.withValues(alpha: 0.18)),
        boxShadow: AtlasShadows.warm,
      ),
      child: Stack(
        children: [
          Positioned.fill(child: AtlasSurfaces.grain(opacity: 0.25)),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => widget.commandController.navigateTo(0),
                      child: Row(
                        children: [
                          _buildLogo(),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Atlas',
                                style: textTheme.displayLarge?.copyWith(
                                  color: AtlasPalette.beige,
                                  fontSize: 30,
                                  letterSpacing: 3,
                                ),
                              ),
                              Text(
                                'Interactive Shell',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AtlasPalette.beige
                                      .withValues(alpha: 0.78),
                                  letterSpacing: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                  color: Color.fromRGBO(249, 244, 231, 0.18), height: 1),
              Expanded(
                child: NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) =>
                      widget.commandController.navigateTo(index),
                  extended: true,
                  backgroundColor: Colors.transparent,
                  groupAlignment: -1,
                  labelType: NavigationRailLabelType.none,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_customize_outlined),
                      selectedIcon: Icon(Icons.dashboard_customize),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.auto_awesome_outlined),
                      selectedIcon: Icon(Icons.auto_awesome),
                      label: Text('Oji'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.currency_bitcoin_outlined),
                      selectedIcon: Icon(Icons.currency_bitcoin),
                      label: Text('Crypto'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.apps_outlined),
                      selectedIcon: Icon(Icons.apps),
                      label: Text('Google Workspace'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.terminal_outlined),
                      selectedIcon: Icon(Icons.terminal),
                      label: Text('Terminal'),
                    ),
                  ],
                ),
              ),
              const Divider(
                  color: Color.fromRGBO(249, 244, 231, 0.18), height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          widget.themeMode == ThemeMode.dark
                              ? Icons.nightlight_round
                              : Icons.wb_sunny_rounded,
                          color: AtlasPalette.beige,
                          size: 18,
                        ),
                        Switch(
                          value: widget.themeMode == ThemeMode.dark,
                          onChanged: (v) => widget.onThemeModeChanged(
                              v ? ThemeMode.dark : ThemeMode.light),
                          thumbColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? AtlasPalette.yellow
                                : AtlasPalette.beige,
                          ),
                          trackColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? AtlasPalette.yellow.withValues(alpha: 0.35)
                                : AtlasPalette.beige.withValues(alpha: 0.25),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Use /nav commands to jump across tabs.',
                        style: textTheme.bodySmall?.copyWith(
                          color: AtlasPalette.beige.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 56,
      height: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/Atlas_Logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AtlasPalette.beige.withValues(alpha: 0.2),
              child: const Icon(
                Icons.language,
                color: AtlasPalette.deepTeal,
                size: 32,
              ),
            );
          },
        ),
      ),
    );
  }

  String _tabTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Oji';
      case 2:
        return 'Crypto';
      case 3:
        return 'Google Workspace';
      case 4:
        return 'Terminal';
      default:
        return 'Atlas';
    }
  }
}
