import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EnterpriseCard extends StatefulWidget {
  final Widget child;
  final bool isHoverable;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;

  const EnterpriseCard({
    super.key,
    required this.child,
    this.isHoverable = true,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.onTap,
    this.boxShadow,
    this.backgroundColor,
  });

  @override
  State<EnterpriseCard> createState() => _EnterpriseCardState();
}

class _EnterpriseCardState extends State<EnterpriseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
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
    final backgroundColor = widget.backgroundColor ?? AppTheme.pureWhite;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                margin:
                    widget.margin ??
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: widget.padding ?? const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(16),
                  color: backgroundColor,
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
                        color: borderColor.withValues(
                          alpha: 0.15 * _elevationAnimation.value,
                        ),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

class EnterpriseCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;
  final Color? iconColor;

  const EnterpriseCardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.primaryBlue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class EnterpriseCardContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const EnterpriseCardContent({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 16),
      child: child,
    );
  }
}

class EnterpriseCardActions extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment alignment;

  const EnterpriseCardActions({
    super.key,
    required this.children,
    this.alignment = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(mainAxisAlignment: alignment, children: children),
    );
  }
}
