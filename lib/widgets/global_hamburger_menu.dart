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
    // Su schermi piccoli, forza sempre espansione per leggibilità
    final isMobile = screenWidth < 480;
    final isSmallTablet = screenWidth >= 480 && screenWidth <= 768;
    final isVerySmall = screenWidth < 600; // Schermi molto piccoli

    final shouldBeExpanded = isDesktop
        ? true
        : (isVerySmall
              ? true
              : isExpanded); // Forza espansione su schermi piccoli

    // Calcola la larghezza appropriata per il dispositivo
    double menuWidth;
    if (shouldBeExpanded) {
      if (isDesktop) {
        menuWidth = 280;
      } else if (isTablet) {
        menuWidth = 260;
      } else if (isVerySmall) {
        // Per schermi molto piccoli, usa la larghezza dello schermo
        menuWidth = screenWidth;
      } else if (isSmallTablet) {
        // Per tablet piccoli, usa una larghezza minima per leggibilità
        menuWidth = screenWidth * 0.6; // 60% della larghezza schermo
        if (menuWidth < 200) menuWidth = 200; // Larghezza minima
      } else if (isMobile) {
        menuWidth = screenWidth * 0.75; // 75% della larghezza schermo su mobile
      } else {
        menuWidth = 240;
      }
    } else {
      // Quando è collassato, mantieni una larghezza minima per l'icona
      menuWidth = 72;
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Se è in caricamento, mostra un indicatore
        if (authProvider.isLoading) {
          return Container(
            width: menuWidth,
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryBlue,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    l10n.getString('loading'),
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Se c'è un errore di autenticazione, mostra un messaggio di errore
        if (authProvider.errorMessage != null) {
          return Container(
            width: menuWidth,
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 32),
                  SizedBox(height: 16),
                  Text(
                    l10n.getString('error_loading_data'),
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Riprova a caricare i dati
                      authProvider.checkAuthenticationStatus();
                    },
                    child: Text(
                      l10n.getString('retry'),
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: menuWidth,
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.verified_user,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  if (!isDesktop && !isVerySmall)
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          onExpansionChanged(false),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.getString('app_title'),
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  onPressed: isVerySmall
                                      ? null
                                      : () => onExpansionChanged(true),
                                  tooltip: isVerySmall
                                      ? null
                                      : l10n.getString('open_menu'),
                                  padding: EdgeInsets.all(2),
                                  constraints: BoxConstraints(
                                    minHeight: 32,
                                    minWidth: 32,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.verified_user,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              // Menu items
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: _buildMenuItems(shouldBeExpanded, l10n),
                  ),
                ),
              ),

              // Logout button
              if (shouldBeExpanded)
                _buildLogoutItem(shouldBeExpanded, l10n)
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    icon: Icon(Icons.logout, color: Colors.red[600], size: 20),
                    onPressed: () => _showLogoutDialog(context, l10n),
                    tooltip: l10n.getString('logout'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuItems(bool isExpanded, AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1200;

    // Menu items basati sul tipo di utente
    List<Map<String, dynamic>> menuItems = [];

    // Admin menu
    if (userType == AppUserType.admin) {
      menuItems = [
        {
          'icon': Icons.dashboard,
          'label': l10n.getString('dashboard'),
          'index': 0,
        },
        {
          'icon': Icons.verified,
          'label': l10n.getString('certifications'),
          'index': 1,
        },
        {
          'icon': Icons.business,
          'label': l10n.getString('legal_entities'),
          'index': 2,
        },
        {
          'icon': Icons.people,
          'label': l10n.getString('certifiers'),
          'index': 3,
        },
        {
          'icon': Icons.settings,
          'label': l10n.getString('settings'),
          'index': 4,
        },
        {'icon': Icons.person, 'label': l10n.getString('profile'), 'index': 5},
      ];
    }
    // Legal Entity menu
    else if (userType == AppUserType.legalEntity) {
      menuItems = [
        {
          'icon': Icons.dashboard,
          'label': l10n.getString('dashboard'),
          'index': 0,
        },
        {
          'icon': Icons.business,
          'label': l10n.getString('legal_entities'),
          'index': 1,
        },
        {
          'icon': Icons.people,
          'label': l10n.getString('certifiers'),
          'index': 2,
        },
        {
          'icon': Icons.settings,
          'label': l10n.getString('settings'),
          'index': 3,
        },
        {'icon': Icons.person, 'label': l10n.getString('profile'), 'index': 4},
      ];
    }
    // Certifier menu
    else if (userType == AppUserType.certifier) {
      menuItems = [
        {
          'icon': Icons.dashboard,
          'label': l10n.getString('dashboard'),
          'index': 0,
        },
        {
          'icon': Icons.verified,
          'label': l10n.getString('certifications'),
          'index': 1,
        },
        {'icon': Icons.person, 'label': l10n.getString('profile'), 'index': 2},
      ];
    }
    // User menu
    else {
      menuItems = [
        {'icon': Icons.person, 'label': l10n.getString('profile'), 'index': 0},
        {
          'icon': Icons.settings,
          'label': l10n.getString('settings'),
          'index': 1,
        },
      ];
    }

    return menuItems.map((item) {
      return _buildMenuItem(
        icon: item['icon'],
        label: item['label'],
        index: item['index'],
        isExpanded: isExpanded,
        isSelected: selectedIndex == item['index'],
        l10n: l10n,
      );
    }).toList();
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isExpanded,
    required bool isSelected,
    required AppLocalizations l10n,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected
            ? AppTheme.primaryBlue.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _handleNavigation(index),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 16 : 8,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.textSecondary,
                  size: 20,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : AppTheme.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutItem(bool isExpanded, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showLogoutDialog(context, l10n),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.red[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.getString('logout'),
                    style: TextStyle(
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(int index) {
    onDestinationSelected(index);
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
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

              try {
                // Logout logic here
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.signOut();

                // Navigate to public home after logout
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/public', (route) => false);
                }
              } catch (e) {
                print('Error during logout: $e');
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
