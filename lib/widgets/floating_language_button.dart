import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';

class FloatingLanguageButton extends StatefulWidget {
  const FloatingLanguageButton({super.key});

  @override
  State<FloatingLanguageButton> createState() => _FloatingLanguageButtonState();
}

class _FloatingLanguageButtonState extends State<FloatingLanguageButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;
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
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          bottom: 20,
          right: 20,
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
                          child: Text(
                            language['flag']!,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.0,
                              color: isSelected
                                  ? AppTheme.pureWhite
                                  : AppTheme.textPrimary,
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
