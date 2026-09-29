import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/project_themes.dart';
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
    final visual = ProjectThemes.of(widget.repo);
    final radius = widget.borderRadius ?? BorderRadius.circular(22);

    final image = Image.network(
      visual.cover,
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
          child: Icon(
            visual.icon,
            size: 58,
            color: visual.primary,
          ),
        ),
      ),
    );

    Widget card = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: visual.primary.withValues(alpha: .18),
        ),
        boxShadow: [
          BoxShadow(
            color: visual.primary.withValues(alpha: .11),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    visual.primary.withValues(alpha: .20),
                    Colors.transparent,
                    visual.secondary.withValues(alpha: .18),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: .03),
                    Colors.black.withValues(alpha: .12),
                    Colors.black.withValues(alpha: .80),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 10,
              child: _Badge(
                text: visual.category,
                color: visual.primary,
                icon: visual.icon,
              ),
            ),
            if (widget.repo.isPrivate)
              Positioned(
                right: 10,
                top: 10,
                child: _Badge(
                  text: 'Privado',
                  color: visual.secondary,
                  icon: Icons.lock_rounded,
                ),
              ),
            if (widget.onFavorite != null)
              Positioned(
                right: 8,
                bottom: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: .40),
                  shape: const CircleBorder(),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: widget.onFavorite,
                    icon: Icon(
                      widget.favorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: widget.favorite
                          ? visual.accent
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            if (widget.showTitle)
              Positioned(
                left: 13,
                right: widget.onFavorite == null ? 13 : 54,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.repo.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.25,
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: visual.accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: visual.accent.withValues(alpha: .55),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.repo.language.isEmpty
                                ? 'Projeto'
                                : widget.repo.language,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFDCE6F3),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
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
    );

    if (widget.heroTag != null) {
      card = Hero(
        tag: widget.heroTag!,
        child: card,
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) => setState(() => pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        scale: pressed ? .978 : 1,
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: card,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: .12),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .26),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: .45,
            ),
          ),
        ],
      ),
    );
  }
}
