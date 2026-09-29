import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

const int coucouPort = 8765;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CoucouApp());
}

@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: CoucouOverlay()),
      ),
    ),
  );
}

enum CoucouState { idle, thinking, working, success, error, sleeping }

extension CoucouStateUI on CoucouState {
  String get label => switch (this) {
        CoucouState.idle => 'Pronto',
        CoucouState.thinking => 'Pensando',
        CoucouState.working => 'Trabalhando',
        CoucouState.success => 'Concluído',
        CoucouState.error => 'Erro',
        CoucouState.sleeping => 'Dormindo',
      };

  String get emoji => switch (this) {
        CoucouState.idle => '•ᴗ•',
        CoucouState.thinking => '•﹏•',
        CoucouState.working => '•̀ᴗ•́',
        CoucouState.success => 'ᵔᴗᵔ',
        CoucouState.error => '×﹏×',
        CoucouState.sleeping => '－ᴗ－',
      };

  IconData get icon => switch (this) {
        CoucouState.idle => Icons.nightlight_round,
        CoucouState.thinking => Icons.auto_awesome,
        CoucouState.working => Icons.terminal,
        CoucouState.success => Icons.check_circle,
        CoucouState.error => Icons.error_outline,
        CoucouState.sleeping => Icons.bedtime,
      };

  Color get color => switch (this) {
        CoucouState.idle => const Color(0xFF7CFFB2),
        CoucouState.thinking => const Color(0xFF9B7BFF),
        CoucouState.working => const Color(0xFF00F0FF),
        CoucouState.success => const Color(0xFF35D07F),
        CoucouState.error => const Color(0xFFFF5D73),
        CoucouState.sleeping => const Color(0xFF7F8EA3),
      };
}

CoucouState? stateFromString(String value) {
  final normalized = value.trim().toLowerCase();
  for (final state in CoucouState.values) {
    if (state.name == normalized) return state;
  }
  return null;
}

class CoucouApp extends StatelessWidget {
  const CoucouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coucou Android',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF060A10),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00F0FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class LocalTermuxBridge {
  HttpServer? _server;

  bool get isRunning => _server != null;

  Future<void> start({
    required Future<void> Function(CoucouState state, String source) onState,
  }) async {
    if (_server != null) return;

    _server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      coucouPort,
      shared: false,
    );

    _server!.listen((request) async {
      void jsonResponse(int status, Map<String, Object?> body) {
        request.response.statusCode = status;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(body));
      }

      try {
        final path = request.uri.path;

        if (path == '/ping') {
          jsonResponse(200, {
            'ok': true,
            'service': 'coucou-android',
            'port': coucouPort,
          });
        } else if (path == '/state') {
          final raw = request.uri.queryParameters['value'] ?? '';
          final source = request.uri.queryParameters['source'] ?? 'termux';
          final next = stateFromString(raw);

          if (next == null) {
            jsonResponse(400, {
              'ok': false,
              'error': 'invalid_state',
              'allowed': CoucouState.values.map((e) => e.name).toList(),
            });
          } else {
            await onState(next, source);
            jsonResponse(200, {
              'ok': true,
              'state': next.name,
              'label': next.label,
            });
          }
        } else {
          jsonResponse(404, {
            'ok': false,
            'routes': [
              '/ping',
              '/state?value=working',
            ],
          });
        }
      } catch (e) {
        jsonResponse(500, {'ok': false, 'error': e.toString()});
      } finally {
        await request.response.close();
      }
    });
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}

class CoucouLog {
  final DateTime time;
  final CoucouState state;
  final String source;

  CoucouLog(this.time, this.state, this.source);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final LocalTermuxBridge bridge = LocalTermuxBridge();
  final List<CoucouLog> logs = [];

  CoucouState state = CoucouState.idle;
  bool overlayPermission = false;
  bool overlayActive = false;
  String bridgeStatus = 'Iniciando';
  StreamSubscription? overlaySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
  }

  Future<void> _setup() async {
    overlaySubscription =
        FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is String) {
        final next = stateFromString(event);
        if (next != null && mounted) setState(() => state = next);
      }
    });

    await _refreshOverlay();

    try {
      await bridge.start(onState: _changeState);
      if (mounted) setState(() => bridgeStatus = 'Online em 127.0.0.1:$coucouPort');
      _addLog(state, 'app');
    } catch (e) {
      if (mounted) setState(() => bridgeStatus = 'Falha: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed) {
      _refreshOverlay();
    }
  }

  void _addLog(CoucouState next, String source) {
    logs.insert(0, CoucouLog(DateTime.now(), next, source));
    if (logs.length > 12) logs.removeLast();
  }

  Future<void> _changeState(CoucouState next, String source) async {
    if (mounted) {
      setState(() {
        state = next;
        _addLog(next, source);
      });
    }

    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.shareData(next.name);
    }
  }

  Future<void> _refreshOverlay() async {
    final permission = await FlutterOverlayWindow.isPermissionGranted();
    final active = await FlutterOverlayWindow.isActive();

    if (!mounted) return;
    setState(() {
      overlayPermission = permission;
      overlayActive = active;
    });
  }

  Future<void> _requestPermission() async {
    await FlutterOverlayWindow.requestPermission();
    await _refreshOverlay();
  }

  Future<void> _startOverlay() async {
    if (!await FlutterOverlayWindow.isPermissionGranted()) {
      await _requestPermission();
      if (!await FlutterOverlayWindow.isPermissionGranted()) return;
    }

    await FlutterOverlayWindow.showOverlay(
      height: 190,
      width: 360,
      alignment: OverlayAlignment.topCenter,
      flag: OverlayFlag.defaultFlag,
      enableDrag: true,
      positionGravity: PositionGravity.auto,
      overlayTitle: 'Coucou Android',
      overlayContent: 'Companheiro do Termux ativo',
      visibility: NotificationVisibility.visibilityPublic,
    );

    await Future.delayed(const Duration(milliseconds: 450));
    await FlutterOverlayWindow.shareData(state.name);
    await _refreshOverlay();
  }

  Future<void> _stopOverlay() async {
    await FlutterOverlayWindow.closeOverlay();
    await _refreshOverlay();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    overlaySubscription?.cancel();
    FlutterOverlayWindow.disposeOverlayListener();
    bridge.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshOverlay,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
            children: [
              const Text(
                'MERAKY LABS • COUCOU',
                style: TextStyle(
                  letterSpacing: 2.5,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8395AC),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Companheiro do\nTermux.',
                style: TextStyle(
                  height: 1.0,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              _PreviewCard(state: state),
              const SizedBox(height: 14),
              _BridgeCard(
                bridgeStatus: bridgeStatus,
                permission: overlayPermission,
                active: overlayActive,
              ),
              const SizedBox(height: 18),
              const Text(
                'Estado',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: CoucouState.values.map((item) {
                  return ChoiceChip(
                    selected: item == state,
                    avatar: Icon(item.icon, size: 17),
                    label: Text(item.label),
                    onSelected: (_) => _changeState(item, 'manual'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: overlayActive ? _stopOverlay : _startOverlay,
                icon: Icon(overlayActive ? Icons.close : Icons.layers),
                label: Text(
                  overlayActive
                      ? 'Fechar mascote flutuante'
                      : 'Mostrar mascote flutuante',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _requestPermission,
                icon: const Icon(Icons.settings_suggest),
                label: const Text('Abrir permissão de sobreposição'),
              ),
              const SizedBox(height: 24),
              _CommandCard(port: coucouPort),
              const SizedBox(height: 24),
              _LogCard(logs: logs),
              const SizedBox(height: 24),
              const _FeaturesCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final CoucouState state;
  const _PreviewCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 205,
      decoration: BoxDecoration(
        color: const Color(0xFF0C1420),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: state.color.withValues(alpha: .24)),
        boxShadow: [
          BoxShadow(
            color: state.color.withValues(alpha: .10),
            blurRadius: 34,
          ),
        ],
      ),
      child: Center(child: CoucouFace(state: state, large: true)),
    );
  }
}

class _BridgeCard extends StatelessWidget {
  final String bridgeStatus;
  final bool permission;
  final bool active;

  const _BridgeCard({
    required this.bridgeStatus,
    required this.permission,
    required this.active,
  });

  Widget badge(String text, bool ok) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: (ok ? const Color(0xFF35D07F) : const Color(0xFFF5B942))
            .withValues(alpha: .10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: ok ? const Color(0xFF62E9A2) : const Color(0xFFFFCF70),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101A28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ponte Termux',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            bridgeStatus,
            style: const TextStyle(color: Color(0xFFA7B6C9)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              badge(
                permission ? 'Overlay autorizado' : 'Overlay pendente',
                permission,
              ),
              badge(active ? 'Mascote ativo' : 'Mascote fechado', active),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommandCard extends StatelessWidget {
  final int port;
  const _CommandCard({required this.port});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1420),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comandos do Termux',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          SelectableText(
            'curl "http://127.0.0.1:$port/state?value=working"',
            style: const TextStyle(
              color: Color(0xFF85F5FF),
              fontFamily: 'monospace',
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Instale o script da pasta termux/ para usar comandos curtos como '
            '`coucou working` e `coucou-run npm run dev`.',
            style: TextStyle(color: Color(0xFFA7B6C9), height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final List<CoucouLog> logs;
  const _LogCard({required this.logs});

  String hhmmss(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}:'
      '${time.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1420),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Eventos recentes',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (logs.isEmpty)
            const Text(
              'Nenhum evento ainda.',
              style: TextStyle(color: Color(0xFF8395AC)),
            )
          else
            ...logs.take(6).map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  children: [
                    Icon(event.state.icon, size: 17, color: event.state.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${event.state.label} • ${event.source}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      hhmmss(event.time),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFF8395AC),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturesCard extends StatelessWidget {
  const _FeaturesCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      'Overlay arrastável estilo Dynamic Island',
      'Estados controlados pelo Termux via localhost',
      'Wrapper automático para sucesso/erro de comandos',
      'Histórico de eventos no painel',
      'Modo Dormindo para quando você parar de programar',
      'Conexão somente em 127.0.0.1 (não exposta ao Wi‑Fi)',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1420),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'V2 adiciona',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Color(0xFF35D07F),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFFB7C5D8),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CoucouOverlay extends StatefulWidget {
  const CoucouOverlay({super.key});

  @override
  State<CoucouOverlay> createState() => _CoucouOverlayState();
}

class _CoucouOverlayState extends State<CoucouOverlay> {
  CoucouState state = CoucouState.idle;
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    subscription = FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is String) {
        final next = stateFromString(event);
        if (next != null && mounted) setState(() => state = next);
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    FlutterOverlayWindow.disposeOverlayListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onDoubleTap: FlutterOverlayWindow.closeOverlay,
          child: Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xF5070D15),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: state.color.withValues(alpha: .42)),
              boxShadow: [
                BoxShadow(
                  color: state.color.withValues(alpha: .20),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CoucouFace(state: state),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COUCOU',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.0,
                        color: Color(0xFF8293A9),
                      ),
                    ),
                    Text(
                      state.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CoucouFace extends StatefulWidget {
  final CoucouState state;
  final bool large;

  const CoucouFace({
    super.key,
    required this.state,
    this.large = false,
  });

  @override
  State<CoucouFace> createState() => _CoucouFaceState();
}

class _CoucouFaceState extends State<CoucouFace>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> pulse;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    pulse = Tween<double>(begin: .95, end: 1.04).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.large ? 118.0 : 56.0;

    return ScaleTransition(
      scale: pulse,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF111C2A),
          border: Border.all(
            color: widget.state.color.withValues(alpha: .55),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.state.color.withValues(alpha: .22),
              blurRadius: widget.large ? 32 : 16,
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.state.emoji,
            style: TextStyle(
              color: widget.state.color,
              fontSize: widget.large ? 29 : 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
