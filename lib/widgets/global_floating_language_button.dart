import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';

class GlobalFloatingLanguageButton extends StatefulWidget {
  const GlobalFloatingLanguageButton({super.key});

  @override
  State<GlobalFloatingLanguageButton> createState() =>
      _GlobalFloatingLanguageButtonState();
}

class _GlobalFloatingLanguageButtonState
    extends State<GlobalFloatingLanguageButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;
  bool _flagsLoaded = false;
  List<Map<String, String>> _cachedLanguages = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Pre-cache language data to avoid delays
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final localeProvider = context.read<LocaleProvider>();
        _cachedLanguages = localeProvider.getSupportedLanguages();
        _preloadFlags();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _preloadFlags() async {
    // Pre-carica le emoji delle bandiere per evitare ritardi
    for (final language in _cachedLanguages) {
      final flag = language['flag']!;
      // Forza il rendering dell'emoji creando un widget temporaneo
      final textPainter = TextPainter(
        text: TextSpan(text: flag, style: const TextStyle(fontSize: 24)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
    }

    // Simula un piccolo delay per assicurarsi che le emoji siano caricate
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      setState(() {
        _flagsLoaded = true;
      });
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Positioned(
          top: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isExpanded) ...[
                ...(_cachedLanguages.isNotEmpty
                        ? _cachedLanguages
                        : localeProvider.getSupportedLanguages())
                    .map((language) {
                      final isSelected =
                          localeProvider.locale.languageCode ==
                          language['code'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Material(
                            elevation: 4,
                            shadowColor: AppTheme.primaryBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(28),
                            child: InkWell(
                              onTap: () {
                                final newLocale = Locale(
                                  language['code']!,
                                  language['code']!.toUpperCase(),
                                );
                                localeProvider.setLocale(newLocale);
                                _toggleExpanded();
                              },
                              borderRadius: BorderRadius.circular(28),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryBlue
                                      : AppTheme.pureWhite,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryBlue
                                        : AppTheme.borderGray,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: _flagsLoaded
                                      ? Text(
                                          language['flag']!,
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: isSelected
                                                ? AppTheme.pureWhite
                                                : AppTheme.textPrimary,
                                          ),
                                        )
                                      : Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppTheme.pureWhite
                                                      .withOpacity(0.3)
                                                : AppTheme.textPrimary
                                                      .withOpacity(0.3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(),
                const SizedBox(height: 8),
              ],

              // Main floating button
              Material(
                elevation: 6,
                shadowColor: AppTheme.primaryBlue.withOpacity(0.4),
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  onTap: _toggleExpanded,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isExpanded ? Icons.close : Icons.language,
                          color: AppTheme.pureWhite,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
