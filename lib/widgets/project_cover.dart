import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/project_covers.dart';
import '../models/project.dart';

class ProjectCover extends StatefulWidget {
  final ProjectRepo repo;
  final double? height;
  final BorderRadius? borderRadius;
  final bool favorite;
  final VoidCallback? onFavorite;
  final bool showTitle;
  final String? heroTag;

  const ProjectCover({
    super.key,
    required this.repo,
    this.height,
    this.borderRadius,
    this.favorite = false,
    this.onFavorite,
    this.showTitle = true,
    this.heroTag,
  });

  @override
  State<ProjectCover> createState() => _ProjectCoverState();
}

class _ProjectCoverState extends State<ProjectCover> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(20);
    final image = Image.network(
      ProjectCovers.getCover(widget.repo),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Image.network(
        widget.repo.socialPreview,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.surface,
          alignment: Alignment.center,
          child: Text(
            widget.repo.name.isEmpty ? 'P' : widget.repo.name[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 58,
              fontWeight: FontWeight.w900,
              color: AppColors.cyan,
            ),
          ),
        ),
      ),
    );

    Widget child = ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .05),
                  Colors.black.withValues(alpha: .10),
                  Colors.black.withValues(alpha: .70),
                ],
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 10,
            child: _Badge(
              text: widget.repo.language,
              color: AppColors.cyan,
            ),
          ),
          if (widget.repo.isPrivate)
            const Positioned(
              right: 10,
              top: 10,
              child: _Badge(
                text: 'PRIVADO',
                color: AppColors.violet,
                icon: Icons.lock,
              ),
            ),
          if (widget.onFavorite != null)
            Positioned(
              right: 9,
              bottom: 8,
              child: Material(
                color: Colors.black.withValues(alpha: .42),
                shape: const CircleBorder(),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.onFavorite,
                  icon: Icon(
                    widget.favorite ? Icons.star : Icons.star_border,
                    color: widget.favorite ? AppColors.amber : Colors.white,
                  ),
                ),
              ),
            ),
          if (widget.showTitle)
            Positioned(
              left: 12,
              right: widget.onFavorite == null ? 12 : 54,
              bottom: 13,
              child: Text(
                widget.repo.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(color: Colors.black87, blurRadius: 8),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.heroTag != null) {
      child = Hero(tag: widget.heroTag!, child: child);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) => setState(() => pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        scale: pressed ? .975 : 1,
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: child,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const _Badge({
    required this.text,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .24),
            blurRadius: 14,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text.isEmpty ? 'PROJETO' : text.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .4,
            ),
          ),
        ],
      ),
    );
  }
}
