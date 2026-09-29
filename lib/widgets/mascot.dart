import 'package:flutter/material.dart';
import '../core/theme.dart';

enum CoucouState { idle, thinking, working, success, error, sleeping }

extension CoucouStateUi on CoucouState {
  String get label => switch (this) {
        CoucouState.idle => 'Pronto',
        CoucouState.thinking => 'Pensando',
        CoucouState.working => 'Trabalhando',
        CoucouState.success => 'Concluído',
        CoucouState.error => 'Erro',
        CoucouState.sleeping => 'Dormindo',
      };
  Color get color => switch (this) {
        CoucouState.idle => AppColors.cyan,
        CoucouState.thinking => AppColors.violet,
        CoucouState.working => AppColors.cyan,
        CoucouState.success => AppColors.green,
        CoucouState.error => AppColors.red,
        CoucouState.sleeping => AppColors.muted,
      };
}

CoucouState? stateFromString(String raw) {
  for (final value in CoucouState.values) {
    if (value.name == raw.trim().toLowerCase()) return value;
  }
  return null;
}

class MascotImage extends StatefulWidget {
  final CoucouState state;
  final double size;
  const MascotImage({super.key, required this.state, this.size = 120});

  @override
  State<MascotImage> createState() => _MascotImageState();
}

class _MascotImageState extends State<MascotImage> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    scale = Tween(begin: .96, end: 1.035).animate(
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
    return ScaleTransition(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.state.color.withValues(alpha: .28),
              blurRadius: 28,
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset('assets/brand/mascot.png', fit: BoxFit.cover),
      ),
    );
  }
}
