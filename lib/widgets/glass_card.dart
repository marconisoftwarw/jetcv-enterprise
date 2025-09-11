import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final bool isHoverable;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double? borderWidth;

  const GlassCard({
    super.key,
    required this.child,
    this.isHoverable = false,
    this.boxShadow,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (widget.isHoverable) {
      setState(() => _isHovered = isHovered);
      if (isHovered) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.borderColor ?? AppTheme.primaryBlue;
    final borderWidth = widget.borderWidth ?? 1.0;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: widget.margin,
              padding: widget.padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                gradient: AppTheme.cardGradient,
                border: Border.all(
                  color: _isHovered
                      ? borderColor.withValues(alpha: 0.3)
                      : AppTheme.borderGray,
                  width: borderWidth,
                ),
                boxShadow: [
                  ...widget.boxShadow ?? [],
                  BoxShadow(
                    color: AppTheme.textPrimary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                  if (_isHovered)
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
