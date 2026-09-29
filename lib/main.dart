import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'core/theme.dart';
import 'screens/dashboard.dart';
import 'widgets/mascot.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CoucouApp());
}

@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: CoucouOverlay()));
}

class CoucouApp extends StatelessWidget {
  const CoucouApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Coucou Projects Hub',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const Dashboard(),
      );
}

class CoucouOverlay extends StatefulWidget {
  const CoucouOverlay({super.key});
  @override
  State<CoucouOverlay> createState() => _CoucouOverlayState();
}

class _CoucouOverlayState extends State<CoucouOverlay> {
  CoucouState state = CoucouState.idle;
  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is String) {
        final next = stateFromString(event);
        if (next != null && mounted) setState(() => state = next);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: GestureDetector(
            onDoubleTap: FlutterOverlayWindow.closeOverlay,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xF20B1220),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: state.color.withValues(alpha: .55)),
                boxShadow: [BoxShadow(color: state.color.withValues(alpha: .24), blurRadius: 25)],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                ClipOval(child: Image.asset('assets/brand/mascot.jpg', width: 56, height: 56, fit: BoxFit.cover)),
                const SizedBox(width: 9),
                Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('COUCOU', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, letterSpacing: 2.3)),
                  Text(state.label, style: TextStyle(color: state.color, fontSize: 15, fontWeight: FontWeight.w900)),
                ]),
              ]),
            ),
          ),
        ),
      );
}
