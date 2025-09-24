import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class MobileTopBar extends StatefulWidget {
  final VoidCallback? onMenuTap;
  final bool isMenuExpanded;
  final String? title;

  const MobileTopBar({
    super.key,
    this.onMenuTap,
    this.isMenuExpanded = false,
    this.title,
  });

  @override
  State<MobileTopBar> createState() => _MobileTopBarState();
}

class _MobileTopBarState extends State<MobileTopBar>
    with TickerProviderStateMixin {
  bool _isLanguageExpanded = false;
  late AnimationController _languageAnimationController;
  late Animation<double> _languageScaleAnimation;

  @override
  void initState() {
    super.initState();
    _languageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _languageScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _languageAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _languageAnimationController.dispose();
    super.dispose();
  }

  void _toggleLanguageExpanded() {
    setState(() {
      _isLanguageExpanded = !_isLanguageExpanded;
    });

    if (_isLanguageExpanded) {
      _languageAnimationController.forward();
    } else {
      _languageAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Container(
          height: 60,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 20,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Pulsante hamburger
              if (widget.onMenuTap != null)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: widget.onMenuTap,
                      child: Icon(
                        widget.isMenuExpanded ? Icons.close : Icons.menu,
                        color: Colors.white,
                        size: isMobile ? 20 : 22,
                      ),
                    ),
                  ),
                ),

              // Spazio tra hamburger e titolo
              if (widget.onMenuTap != null) SizedBox(width: isMobile ? 12 : 16),

              // Titolo (se presente)
              if (widget.title != null)
                Expanded(
                  child: Text(
                    widget.title!,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Spazio flessibile
              const Spacer(),

              // Pulsanti di cambio lingua
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsante principale lingua
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _toggleLanguageExpanded,
                        child: Icon(
                          Icons.language,
                          color: Colors.white,
                          size: isMobile ? 20 : 22,
                        ),
                      ),
                    ),
                  ),

                  // Pulsanti lingua espansi
                  if (_isLanguageExpanded) ...[
                    SizedBox(width: isMobile ? 8 : 12),
                    ...localeProvider.getSupportedLanguages().map((language) {
                      final isSelected =
                          localeProvider.locale.languageCode ==
                          language['code'];
                      return Container(
                        margin: EdgeInsets.only(right: isMobile ? 8 : 12),
                        child: ScaleTransition(
                          scale: _languageScaleAnimation,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryBlue,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  final newLocale = Locale(
                                    language['code']!,
                                    language['code']!.toUpperCase(),
                                  );
                                  localeProvider.setLocale(newLocale);
                                  _toggleLanguageExpanded();
                                },
                                child: Center(
                                  child: Text(
                                    language['flag']!,
                                    style: TextStyle(
                                      fontSize: isMobile ? 18 : 20,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
