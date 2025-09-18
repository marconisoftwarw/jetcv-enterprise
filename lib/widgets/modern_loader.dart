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
  late AnimationController _pulseAnimationController;
  late AnimationController _waveAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Animazione principale del loader
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Animazione del pulse
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    // Animazione delle onde
    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveAnimationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _loadingAnimationController.dispose();
    _pulseAnimationController.dispose();
    _waveAnimationController.dispose();
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.02),
            AppTheme.lightGrey.withValues(alpha: 0.05),
            AppTheme.primaryBlue.withValues(alpha: 0.03),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Onde di sfondo animate
          ...List.generate(3, (index) {
            final delay = index * 0.3;
            final animationValue = (_waveAnimation.value + delay) % 1.0;
            final opacity = (1.0 - animationValue) * 0.1;
            final scale = 0.5 + (animationValue * 1.5);

            return Positioned.fill(
              child: AnimatedBuilder(
                animation: _waveAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.primaryBlue.withValues(alpha: 0.1),
                              AppTheme.primaryBlue.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          // Contenuto principale
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _scaleAnimation,
                _pulseAnimation,
                _fadeAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Container principale del loader con effetti moderni
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: widget.isTablet ? 240 : 200,
                                height: widget.isTablet ? 240 : 200,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.pureWhite,
                                      AppTheme.pureWhite.withValues(
                                        alpha: 0.95,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    widget.isTablet ? 40 : 32,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.primaryBlue.withValues(
                                      alpha: 0.1,
                                    ),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    // Shadow principale con effetto glow
                                    BoxShadow(
                                      color: AppTheme.primaryBlue.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: widget.isTablet ? 80 : 60,
                                      offset: const Offset(0, 16),
                                      spreadRadius: 5,
                                    ),
                                    // Shadow secondaria per profondità
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: widget.isTablet ? 40 : 30,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 2,
                                    ),
                                    // Shadow interna per effetto glass
                                    BoxShadow(
                                      color: AppTheme.pureWhite.withValues(
                                        alpha: 0.8,
                                      ),
                                      blurRadius: 1,
                                      offset: const Offset(0, -1),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Loader animato con effetti premium
                                    AnimatedBuilder(
                                      animation: _fadeAnimation,
                                      builder: (context, child) {
                                        return Opacity(
                                          opacity: _fadeAnimation.value,
                                          child: Container(
                                            width: widget.isTablet ? 100 : 80,
                                            height: widget.isTablet ? 100 : 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    widget.isTablet ? 50 : 40,
                                                  ),
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  AppTheme.primaryBlue,
                                                  AppTheme.primaryBlue
                                                      .withValues(alpha: 0.9),
                                                  AppTheme.primaryBlue
                                                      .withValues(alpha: 0.8),
                                                  AppTheme.primaryBlue
                                                      .withValues(alpha: 0.95),
                                                ],
                                                stops: const [
                                                  0.0,
                                                  0.3,
                                                  0.7,
                                                  1.0,
                                                ],
                                              ),
                                              boxShadow: [
                                                // Glow esterno
                                                BoxShadow(
                                                  color: AppTheme.primaryBlue
                                                      .withValues(alpha: 0.4),
                                                  blurRadius: widget.isTablet
                                                      ? 30
                                                      : 20,
                                                  offset: const Offset(0, 8),
                                                  spreadRadius: 3,
                                                ),
                                                // Ombra interna per profondità
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: widget.isTablet
                                                      ? 15
                                                      : 10,
                                                  offset: const Offset(0, 4),
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                // Cerchio di sfondo con animazione
                                                AnimatedBuilder(
                                                  animation: _pulseAnimation,
                                                  builder: (context, child) {
                                                    return Transform.scale(
                                                      scale:
                                                          _pulseAnimation.value,
                                                      child: Container(
                                                        width: widget.isTablet
                                                            ? 85
                                                            : 68,
                                                        height: widget.isTablet
                                                            ? 85
                                                            : 68,
                                                        decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          gradient: RadialGradient(
                                                            colors: [
                                                              AppTheme.pureWhite
                                                                  .withValues(
                                                                    alpha: 0.3,
                                                                  ),
                                                              AppTheme.pureWhite
                                                                  .withValues(
                                                                    alpha: 0.1,
                                                                  ),
                                                              Colors
                                                                  .transparent,
                                                            ],
                                                            stops: const [
                                                              0.0,
                                                              0.7,
                                                              1.0,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),

                                                // Loader principale con animazione fluida
                                                SizedBox(
                                                  width: widget.isTablet
                                                      ? 70
                                                      : 55,
                                                  height: widget.isTablet
                                                      ? 70
                                                      : 55,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: widget.isTablet
                                                        ? 5
                                                        : 4,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(AppTheme.pureWhite),
                                                    strokeCap: StrokeCap.round,
                                                  ),
                                                ),

                                                // Icona centrale con animazione migliorata
                                                AnimatedBuilder(
                                                  animation: _fadeAnimation,
                                                  builder: (context, child) {
                                                    return Transform.scale(
                                                      scale:
                                                          0.75 +
                                                          (0.25 *
                                                              _fadeAnimation
                                                                  .value),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: AppTheme
                                                                  .pureWhite
                                                                  .withValues(
                                                                    alpha: 0.2,
                                                                  ),
                                                            ),
                                                        padding: EdgeInsets.all(
                                                          widget.isTablet
                                                              ? 8
                                                              : 6,
                                                        ),
                                                        child: Icon(
                                                          widget.icon ??
                                                              Icons
                                                                  .verified_user,
                                                          color: AppTheme
                                                              .pureWhite,
                                                          size: widget.isTablet
                                                              ? 28
                                                              : 22,
                                                        ),
                                                      ),
                                                    );
                                                  },
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
                                              horizontal: widget.isTablet
                                                  ? 24
                                                  : 20,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  widget.title ??
                                                      l10n.getString('loading'),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: widget.isTablet
                                                        ? 20
                                                        : 17,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppTheme.primaryBlack,
                                                    letterSpacing: 0.3,
                                                    height: 1.2,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: widget.isTablet
                                                      ? 10
                                                      : 8,
                                                ),
                                                Text(
                                                  widget.subtitle ??
                                                      l10n.getString(
                                                        'please_wait',
                                                      ),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: widget.isTablet
                                                        ? 15
                                                        : 13,
                                                    color:
                                                        AppTheme.textSecondary,
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
                            );
                          },
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
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isTablet ? 24 : 20,
            vertical: widget.isTablet ? 16 : 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.pureWhite,
                AppTheme.pureWhite.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(widget.isTablet ? 30 : 24),
            border: Border.all(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                blurRadius: widget.isTablet ? 25 : 18,
                offset: const Offset(0, 6),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: widget.isTablet ? 12 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final offset = (index * 0.2);
              final animationValue = (_pulseAnimation.value + offset) % 1.0;

              // Animazione più fluida e elegante
              final progress = (animationValue * 2 - 1).abs();
              final opacity = (0.3 + (0.7 * (1.0 - progress))).clamp(0.3, 1.0);
              final scale = (0.5 + (0.5 * (1.0 - progress))).clamp(0.5, 1.0);

              // Animazione di traslazione verticale più pronunciata
              final translateY =
                  (progress * (widget.isTablet ? 8 : 6)) -
                  (widget.isTablet ? 4 : 3);

              // Rotazione per effetto più dinamico
              final rotation = progress * 0.5;

              return Transform.translate(
                offset: Offset(0, translateY),
                child: Transform.scale(
                  scale: scale,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: widget.isTablet ? 8 : 6,
                      ),
                      width: widget.isTablet ? 14 : 10,
                      height: widget.isTablet ? 14 : 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryBlue.withValues(alpha: opacity),
                            AppTheme.primaryBlue.withValues(
                              alpha: opacity * 0.8,
                            ),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: opacity > 0.7
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: widget.isTablet ? 15 : 10,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 2,
                                ),
                              ]
                            : opacity > 0.5
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: widget.isTablet ? 8 : 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
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
