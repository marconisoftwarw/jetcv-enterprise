import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';

class FloatingLanguageButton extends StatefulWidget {
  final double? topPosition;
  final double? rightPosition;

  const FloatingLanguageButton({
    super.key,
    this.topPosition,
    this.rightPosition,
  });

  @override
  State<FloatingLanguageButton> createState() => _FloatingLanguageButtonState();
}

class _FloatingLanguageButtonState extends State<FloatingLanguageButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;
  List<Map<String, String>> _cachedLanguages = [];
  bool _flagsLoaded = false;

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
        text: TextSpan(text: flag, style: const TextStyle(fontSize: 18)),
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
        // Use cached languages if available, otherwise get from provider
        final languages = _cachedLanguages.isNotEmpty
            ? _cachedLanguages
            : localeProvider.getSupportedLanguages();

        return Positioned(
          top: widget.topPosition ?? 20,
          right: widget.rightPosition ?? 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Language options (appear when expanded)
              if (_isExpanded) ...[
                ...languages.map((language) {
                  final isSelected =
                      localeProvider.locale.languageCode == language['code'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: FloatingActionButton(
                        mini: true,
                        heroTag: "lang_${language['code']}",
                        onPressed: () {
                          final newLocale = Locale(
                            language['code']!,
                            language['code']!.toUpperCase(),
                          );
                          localeProvider.setLocale(newLocale);
                          _toggleExpanded();
                        },
                        backgroundColor: isSelected
                            ? AppTheme.primaryBlue
                            : AppTheme.pureWhite,
                        child: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          child: _flagsLoaded
                              ? Text(
                                  language['flag']!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    height: 1.0,
                                    color: isSelected
                                        ? AppTheme.pureWhite
                                        : AppTheme.textPrimary,
                                  ),
                                )
                              : Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.pureWhite.withOpacity(0.3)
                                        : AppTheme.textPrimary.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
              ],

              // Main floating button
              FloatingActionButton(
                heroTag: "main_lang_button",
                onPressed: _toggleExpanded,
                backgroundColor: AppTheme.primaryBlue,
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isExpanded ? Icons.close : Icons.language,
                    color: AppTheme.pureWhite,
                    size: 20,
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
