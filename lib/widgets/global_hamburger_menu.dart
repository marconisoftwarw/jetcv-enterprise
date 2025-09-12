import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/user_type_service.dart';

class GlobalHamburgerMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final bool isExpanded;
  final Function(bool) onExpansionChanged;
  final BuildContext context;
  final AppUserType? userType;

  const GlobalHamburgerMenu({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.context,
    this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1200;

    // Su desktop, il menu è sempre aperto
    final shouldBeExpanded = isDesktop ? true : isExpanded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: shouldBeExpanded ? (isDesktop ? 280 : 260) : 72,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header del menu
          Container(
            height: shouldBeExpanded ? 120 : 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: shouldBeExpanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.verified_user,
                                color: Colors.white,
                                size: 32,
                              ),
                              if (!isDesktop)
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () => onExpansionChanged(false),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'JetCV',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            l10n.getString('welcome_back'),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () => onExpansionChanged(true),
                            tooltip: l10n.getString('open_menu'),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            Icons.verified_user,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                ..._buildMenuItems(shouldBeExpanded, l10n),
                const Divider(height: 32),
                _buildLogoutItem(isExpanded: shouldBeExpanded, l10n: l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(bool isExpanded, AppLocalizations l10n) {
    switch (userType ?? AppUserType.user) {
      case AppUserType.admin:
        return [
          _buildMenuItem(
            icon: Icons.dashboard_outlined,
            title: l10n.getString('dashboard'),
            index: 0,
            isExpanded: isExpanded,
          ),
          _buildMenuItem(
            icon: Icons.verified_user_outlined,
            title: l10n.getString('certifications'),
            index: 1,
            isExpanded: isExpanded,
          ),
          _buildMenuItem(
            icon: Icons.business_outlined,
            title: l10n.getString('legal_entity'),
            index: 2,
            isExpanded: isExpanded,
          ),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: l10n.getString('settings'),
            index: 3,
            isExpanded: isExpanded,
          ),
          _buildMenuItem(
            icon: Icons.person_outline,
            title: l10n.getString('profile'),
            index: 4,
            isExpanded: isExpanded,
          ),
        ];

      case AppUserType.legalEntity:
        return [
          _buildMenuItem(
            icon: Icons.dashboard_outlined,
            title: l10n.getString('dashboard'),
            index: 0,
            isExpanded: isExpanded,
          ),
          _buildMenuItem(
            icon: Icons.business_outlined,
            title: l10n.getString('legal_entity'),
            index: 1,
            isExpanded: isExpanded,
          ),
          _buildMenuItem(
            icon: Icons.person_outline,
            title: l10n.getString('profile'),
            index: 2,
            isExpanded: isExpanded,
          ),
        ];

      case AppUserType.certifier:
        return [
          _buildMenuItem(
            icon: Icons.dashboard_outlined,
            title: l10n.getString('dashboard'),
            index: 0,
            isExpanded: isExpanded,
          ),
          _buildMenuItem(
            icon: Icons.verified_user_outlined,
            title: l10n.getString('certifications'),
            index: 1,
            isExpanded: isExpanded,
          ),
          _buildMenuItem(
            icon: Icons.person_outline,
            title: l10n.getString('profile'),
            index: 2,
            isExpanded: isExpanded,
          ),
        ];

      case AppUserType.user:
      default:
        return [
          _buildMenuItem(
            icon: Icons.dashboard_outlined,
            title: l10n.getString('dashboard'),
            index: 0,
            isExpanded: isExpanded,
          ),
          _buildMenuItem(
            icon: Icons.person_outline,
            title: l10n.getString('profile'),
            index: 1,
            isExpanded: isExpanded,
          ),
        ];
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    required bool isExpanded,
  }) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF2563EB).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF2563EB) : Colors.grey[600],
          size: 24,
        ),
        title: isExpanded
            ? Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              )
            : null,
        onTap: () => _handleNavigation(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 16 : 8,
          vertical: 8,
        ),
      ),
    );
  }

  Widget _buildLogoutItem({
    required bool isExpanded,
    required AppLocalizations l10n,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.logout, color: Colors.red[600], size: 24),
        title: isExpanded
            ? Text(
                l10n.getString('logout'),
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              )
            : null,
        onTap: () => _showLogoutDialog(l10n),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 16 : 8,
          vertical: 8,
        ),
      ),
    );
  }

  void _handleNavigation(int index) {
    // Chiama il callback del widget padre
    onDestinationSelected(index);
  }

  void _showLogoutDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red[600]),
            const SizedBox(width: 12),
            Text(l10n.getString('logout_confirmation')),
          ],
        ),
        content: Text(l10n.getString('logout_confirmation_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.getString('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Mostra loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    Center(child: CircularProgressIndicator()),
              );

              try {
                final authProvider = context.read<AuthProvider>();
                await authProvider.signOut();

                if (context.mounted) {
                  Navigator.of(context).pop(); // Chiudi loading
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop(); // Chiudi loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.getString('logout_error')}: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.getString('logout')),
          ),
        ],
      ),
    );
  }
}
