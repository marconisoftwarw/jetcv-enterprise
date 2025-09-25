import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_type_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class DynamicSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const DynamicSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userType = authProvider.userType ?? AppUserType.user;

        return Column(
          children: [
            // Navigation Rail principale
            Expanded(
              child: NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: NavigationRailLabelType.all,
                destinations: _getDestinationsForUserType(userType, l10n),
                backgroundColor: Colors.transparent,
                selectedIconTheme: IconThemeData(
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
                unselectedIconTheme: IconThemeData(
                  color: AppTheme.textGray,
                  size: 24,
                ),
                selectedLabelTextStyle: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelTextStyle: TextStyle(
                  color: AppTheme.textGray,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                indicatorColor: AppTheme.lightBlue,
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Pulsante di logout in basso
            Container(
              margin: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () => _showLogoutDialog(context, authProvider),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.errorRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: AppTheme.errorRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.getString('logout'),
                        style: TextStyle(
                          color: AppTheme.errorRed,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<NavigationRailDestination> _getDestinationsForUserType(
    AppUserType userType,
    AppLocalizations l10n,
  ) {
    switch (userType) {
      case AppUserType.admin:
        return _getAdminDestinations(l10n);
      case AppUserType.legalEntity:
        return _getLegalEntityDestinations(l10n);
      case AppUserType.certifier:
        return _getCertifierDestinations(l10n);
      case AppUserType.user:
        return _getUserDestinations(l10n);
    }
  }

  List<NavigationRailDestination> _getAdminDestinations(AppLocalizations l10n) {
    return [
      NavigationRailDestination(
        icon: const Icon(Icons.dashboard_rounded),
        selectedIcon: const Icon(Icons.dashboard_rounded),
        label: Text(l10n.getString('dashboard')),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.verified_rounded),
        selectedIcon: const Icon(Icons.verified_rounded),
        label: Text(l10n.getString('certifications')),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.business_rounded),
        selectedIcon: const Icon(Icons.business_rounded),
        label: Text(l10n.getString('legal_entities')),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.settings_rounded),
        selectedIcon: const Icon(Icons.settings_rounded),
        label: Text(l10n.getString('settings')),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.person_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: Text(l10n.getString('profile')),
      ),
    ];
  }

  List<NavigationRailDestination> _getLegalEntityDestinations(
    AppLocalizations l10n,
  ) {
    return [
      NavigationRailDestination(
        icon: const Icon(Icons.dashboard_rounded),
        selectedIcon: const Icon(Icons.dashboard_rounded),
        label: Text(l10n.getString('dashboard')),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.verified_rounded),
        selectedIcon: const Icon(Icons.verified_rounded),
        label: Text(l10n.getString('my_certifications')),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.person_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: Text(l10n.getString('profile')),
      ),
    ];
  }

  List<NavigationRailDestination> _getCertifierDestinations(
    AppLocalizations l10n,
  ) {
    return [
      NavigationRailDestination(
        icon: const Icon(Icons.verified_rounded),
        selectedIcon: const Icon(Icons.verified_rounded),
        label: Text(l10n.getString('certifications')),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.person_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: Text(l10n.getString('profile')),
      ),
    ];
  }

  List<NavigationRailDestination> _getUserDestinations(AppLocalizations l10n) {
    return [
      NavigationRailDestination(
        icon: const Icon(Icons.person_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: Text(l10n.getString('profile')),
      ),
    ];
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: AppTheme.errorRed, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.getString('logout'),
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            l10n.getString('logout_confirmation'),
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.getString('cancel'),
                style: TextStyle(
                  color: AppTheme.textGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.signOut();

                // Navigate to public home after logout
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: AppTheme.pureWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                l10n.getString('logout'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
