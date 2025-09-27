import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class PublicTopBar extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final String? title;
  final List<Widget>? actions;

  const PublicTopBar({
    super.key,
    this.showBackButton = false,
    this.onBackPressed,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768;
    final isMobile = screenWidth <= 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
        vertical: isDesktop ? 16 : 12,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0E27),
            Color(0xFF1A1F3A),
            Color(0xFF2D1B69),
            Color(0xFF6366F1),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMobile
          ? _buildMobileLayout(context, l10n)
          : _buildDesktopLayout(context, l10n, isDesktop),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // Top row with logo, title, and menu
        Row(
          children: [
            // Back button (if needed)
            if (showBackButton) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  ),
                ),
                child: IconButton(
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: AppTheme.primaryBlue,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Logo and app name
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.verified_user_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppConfig.appName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Mobile menu button
            _buildMobileMenuButton(context, l10n),
          ],
        ),

        // Title (if provided)
        if (title != null) ...[
          const SizedBox(height: 12),
          Text(
            title!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    return Row(
      children: [
        // Back button (if needed)
        if (showBackButton) ...[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: IconButton(
              onPressed: onBackPressed ?? () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppTheme.primaryBlue,
                size: 18,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 16),
        ],

        // Logo and app name
        Row(
          children: [
            Container(
              width: isDesktop ? 40 : 32,
              height: isDesktop ? 40 : 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.verified_user_rounded,
                color: Colors.white,
                size: isDesktop ? 24 : 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppConfig.appName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: isDesktop ? 20 : 18,
              ),
            ),
          ],
        ),

        const Spacer(),

        // Navigation items
        _buildNavItem(
          context,
          l10n.getString('public_cvs'),
          () => Navigator.pushNamed(context, '/cv-list'),
        ),
        const SizedBox(width: 24),
        _buildNavItem(
          context,
          l10n.getString('pricing'),
          () => Navigator.pushNamed(context, '/legal-entity/pricing'),
        ),
        const SizedBox(width: 24),
        _buildNavItem(
          context,
          l10n.getString('features_title'),
          () => Navigator.pushNamed(context, '/features'),
        ),
        const SizedBox(width: 24),
        _buildNavItem(
          context,
          l10n.getString('contacts_title'),
          () => Navigator.pushNamed(context, '/contacts'),
        ),
        const SizedBox(width: 24),

        // Login button
        _buildLoginButton(context, l10n, isDesktop),

        const SizedBox(width: 16),

        // Language selector
        _buildLanguageSelector(context, isDesktop),
      ],
    );
  }

  Widget _buildMobileMenuButton(BuildContext context, AppLocalizations l10n) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.white, size: 24),
      color: const Color(0xFF1A1F3A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'cvs',
          child: Row(
            children: [
              const Icon(Icons.list, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.getString('public_cvs'),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'pricing',
          child: Row(
            children: [
              const Icon(Icons.euro, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.getString('pricing'),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'features',
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.getString('features_title'),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'contacts',
          child: Row(
            children: [
              const Icon(Icons.contact_support, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.getString('contacts_title'),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'login',
          child: Row(
            children: [
              const Icon(Icons.login, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.getString('login'),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'language',
          child: Row(
            children: [
              const Icon(Icons.language, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('Language', style: const TextStyle(color: Colors.white)),
              const Spacer(),
              _buildLanguageSelector(context, false),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'cvs':
            Navigator.pushNamed(context, '/cv-list');
            break;
          case 'pricing':
            Navigator.pushNamed(context, '/legal-entity/pricing');
            break;
          case 'features':
            Navigator.pushNamed(context, '/features');
            break;
          case 'contacts':
            Navigator.pushNamed(context, '/contacts');
            break;
          case 'login':
            Navigator.pushNamed(context, '/login');
            break;
          case 'language':
            // Language selector is handled by the dropdown itself
            break;
        }
      },
    );
  }

  Widget _buildNavItem(BuildContext context, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isDesktop,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/login'),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 20 : 16,
              vertical: isDesktop ? 10 : 8,
            ),
            child: Text(
              l10n.getString('login'),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isDesktop ? 15 : 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, bool isDesktop) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 8 : 6,
            vertical: isDesktop ? 4 : 2,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Locale>(
              value: localeProvider.locale,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: isDesktop ? 16 : 14,
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: isDesktop ? 14 : 12,
                fontWeight: FontWeight.w500,
              ),
              items: localeProvider.getSupportedLanguages().map((language) {
                return DropdownMenuItem<Locale>(
                  value: Locale(
                    language['code']!,
                    language['code']!.toUpperCase(),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        language['flag']!,
                        style: TextStyle(fontSize: isDesktop ? 14 : 12),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 6),
                        Text(
                          language['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  localeProvider.setLocale(newLocale);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
