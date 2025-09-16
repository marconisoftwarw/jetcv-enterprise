import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class ModernLoader extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final bool isTablet;

  const ModernLoader({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    required this.isTablet,
  });

  @override
  State<ModernLoader> createState() => _ModernLoaderState();
}

class _ModernLoaderState extends State<ModernLoader>
    with TickerProviderStateMixin {
  late AnimationController _loadingAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.lightGrey.withValues(alpha: 0.03),
            AppTheme.lightGrey.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Container principale del loader con shadow perfetto
                    Container(
                      width: widget.isTablet ? 220 : 180,
                      height: widget.isTablet ? 220 : 180,
                      decoration: BoxDecoration(
                        color: AppTheme.pureWhite,
                        borderRadius: BorderRadius.circular(
                          widget.isTablet ? 36 : 28,
                        ),
                        boxShadow: [
                          // Shadow principale
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                            blurRadius: widget.isTablet ? 60 : 45,
                            offset: const Offset(0, 12),
                            spreadRadius: 3,
                          ),
                          // Shadow secondaria per profondità
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: widget.isTablet ? 30 : 22,
                            offset: const Offset(0, 6),
                            spreadRadius: 1,
                          ),
                          // Shadow di sfondo
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: widget.isTablet ? 15 : 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Loader animato con gradiente perfetto
                          AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _fadeAnimation.value,
                                child: Container(
                                  width: widget.isTablet ? 90 : 70,
                                  height: widget.isTablet ? 90 : 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      widget.isTablet ? 45 : 35,
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.primaryBlue,
                                        AppTheme.primaryBlue.withValues(
                                          alpha: 0.85,
                                        ),
                                        AppTheme.primaryBlue.withValues(
                                          alpha: 0.95,
                                        ),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryBlue.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: widget.isTablet ? 20 : 15,
                                        offset: const Offset(0, 6),
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Loader principale con animazione fluida
                                      SizedBox(
                                        width: widget.isTablet ? 65 : 50,
                                        height: widget.isTablet ? 65 : 50,
                                        child: CircularProgressIndicator(
                                          strokeWidth: widget.isTablet
                                              ? 4.5
                                              : 3.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppTheme.pureWhite,
                                              ),
                                          strokeCap: StrokeCap.round,
                                        ),
                                      ),
                                      // Icona centrale con animazione
                                      Transform.scale(
                                        scale:
                                            0.8 + (0.2 * _fadeAnimation.value),
                                        child: Icon(
                                          widget.icon ?? Icons.hourglass_empty,
                                          color: AppTheme.pureWhite,
                                          size: widget.isTablet ? 32 : 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: widget.isTablet ? 28 : 22),

                          // Testo di caricamento centrato perfettamente
                          AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _fadeAnimation.value,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: widget.isTablet ? 24 : 20,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.title ??
                                            l10n.getString('loading'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: widget.isTablet ? 20 : 17,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryBlack,
                                          letterSpacing: 0.3,
                                          height: 1.2,
                                        ),
                                      ),
                                      SizedBox(
                                        height: widget.isTablet ? 10 : 8,
                                      ),
                                      Text(
                                        widget.subtitle ??
                                            l10n.getString('please_wait'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: widget.isTablet ? 15 : 13,
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.2,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: widget.isTablet ? 36 : 28),

                    // Indicatori puntini animati perfetti
                    _buildAnimatedDots(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return AnimatedBuilder(
      animation: _loadingAnimationController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isTablet ? 20 : 16,
            vertical: widget.isTablet ? 12 : 10,
          ),
          decoration: BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.circular(widget.isTablet ? 25 : 20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                blurRadius: widget.isTablet ? 20 : 15,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: widget.isTablet ? 10 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final offset = (index * 0.25);
              final animationValue =
                  (_loadingAnimationController.value + offset) % 1.0;

              // Animazione più fluida e elegante
              final progress = (animationValue * 2 - 1).abs();
              final opacity = (0.25 + (0.75 * (1.0 - progress))).clamp(
                0.25,
                1.0,
              );
              final scale = (0.6 + (0.4 * (1.0 - progress))).clamp(0.6, 1.0);

              // Animazione di traslazione verticale
              final translateY =
                  (progress * (widget.isTablet ? 6 : 4)) -
                  (widget.isTablet ? 3 : 2);

              return Transform.translate(
                offset: Offset(0, translateY),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: widget.isTablet ? 10 : 8,
                    ),
                    width: widget.isTablet ? 16 : 12,
                    height: widget.isTablet ? 16 : 12,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: opacity),
                      shape: BoxShape.circle,
                      boxShadow: opacity > 0.8
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: widget.isTablet ? 12 : 9,
                                offset: const Offset(0, 3),
                                spreadRadius: 1,
                              ),
                            ]
                          : opacity > 0.6
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: widget.isTablet ? 8 : 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
