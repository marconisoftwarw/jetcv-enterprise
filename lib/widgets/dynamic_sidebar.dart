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
        // Ensure user type is loaded if not available
        if (authProvider.isAuthenticated && authProvider.userType == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print(
              '🔄 DynamicSidebar: User type not loaded, ensuring it\'s loaded...',
            );
            authProvider.ensureUserTypeLoaded();
          });
        }

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
                selectedIconTheme: IconThemeData(color: Colors.white, size: 24),
                unselectedIconTheme: IconThemeData(
                  color: Colors.white.withOpacity(0.7),
                  size: 24,
                ),
                selectedLabelTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelTextStyle: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                indicatorColor: Colors.white.withOpacity(0.2),
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
    print('🔍 DynamicSidebar: Getting destinations for user type: $userType');

    switch (userType) {
      case AppUserType.admin:
        print('🔍 DynamicSidebar: Returning admin destinations');
        return _getAdminDestinations(l10n);
      case AppUserType.legalEntity:
        print('🔍 DynamicSidebar: Returning legal entity destinations');
        return _getLegalEntityDestinations(l10n);
      case AppUserType.certifier:
        print('🔍 DynamicSidebar: Returning certifier destinations');
        return _getCertifierDestinations(l10n);
      case AppUserType.user:
        print('🔍 DynamicSidebar: Returning user destinations');
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
    print(
      '🔍 DynamicSidebar _getLegalEntityDestinations: Creating legal entity menu items',
    );
    print(
      '🔍 DynamicSidebar _getLegalEntityDestinations: Dashboard, Certifications, Certifiers, Profile',
    );

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
        icon: const Icon(Icons.people_rounded),
        selectedIcon: const Icon(Icons.people_rounded),
        label: Text(l10n.getString('certifiers')),
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

                try {
                  print('🔄 Dynamic Sidebar: Starting logout process...');
                  await authProvider.signOut();
                  print('✅ Dynamic Sidebar: Auth signOut completed');

                  // Wait a bit to ensure auth state is updated
                  await Future.delayed(const Duration(milliseconds: 100));

                  // Force navigation immediately after logout
                  if (context.mounted) {
                    print(
                      '🔄 Dynamic Sidebar: Context is mounted, attempting navigation...',
                    );
                    try {
                      // Check if Navigator is available
                      final navigator = Navigator.of(
                        context,
                        rootNavigator: true,
                      );
                      print(
                        '🔄 Dynamic Sidebar: Navigator found, navigating to /',
                      );
                      navigator.pushNamedAndRemoveUntil('/', (route) => false);
                      print(
                        '✅ Dynamic Sidebar: Navigation to public home successful',
                      );
                    } catch (navError) {
                      print('❌ Dynamic Sidebar: Navigation error: $navError');
                      print(
                        '🔄 Dynamic Sidebar: Attempting fallback navigation...',
                      );
                      // Fallback: try to navigate after a delay
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (context.mounted) {
                          try {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamedAndRemoveUntil('/', (route) => false);
                            print(
                              '✅ Dynamic Sidebar: Fallback navigation successful',
                            );
                          } catch (fallbackError) {
                            print(
                              '❌ Dynamic Sidebar: Fallback navigation failed: $fallbackError',
                            );
                          }
                        }
                      });
                    }
                  } else {
                    print(
                      '❌ Dynamic Sidebar: Context not mounted, cannot navigate',
                    );
                  }
                } catch (e) {
                  print('Error during logout: $e');
                  // Show error message to user
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.getString('logout_error') ?? 'Logout failed',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
