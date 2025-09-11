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

        return NavigationRail(
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
        icon: const Icon(Icons.people_rounded),
        selectedIcon: const Icon(Icons.people_rounded),
        label: Text(l10n.getString('users')),
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
        icon: const Icon(Icons.analytics_rounded),
        selectedIcon: const Icon(Icons.analytics_rounded),
        label: Text(l10n.getString('analytics')),
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
}
