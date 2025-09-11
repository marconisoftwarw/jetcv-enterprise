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
        return Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Language options (appear when expanded)
              if (_isExpanded) ...[
                ...localeProvider.getSupportedLanguages().map((language) {
                  final isSelected =
                      localeProvider.locale.languageCode == language['code'];
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
                              child: Text(
                                language['flag']!,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: isSelected
                                      ? AppTheme.pureWhite
                                      : AppTheme.textPrimary,
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
