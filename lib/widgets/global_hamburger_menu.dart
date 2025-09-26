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

    // Definizione delle breakpoints per una migliore responsività
    final isMobile = screenWidth < 600;
    final isSmallTablet = screenWidth >= 600 && screenWidth <= 900;
    final isLargeTablet = screenWidth > 900 && screenWidth <= 1200;
    final isVerySmall = screenWidth < 480; // Schermi molto piccoli
    final isExtraSmall = screenWidth < 360; // Schermi extra piccoli

    // Logica di espansione più intelligente
    final shouldBeExpanded = isDesktop
        ? true
        : (isVerySmall ? true : isExpanded);

    // Calcola la larghezza in modo più responsive
    double menuWidth;
    if (shouldBeExpanded) {
      if (isDesktop) {
        menuWidth = 280;
      } else if (isLargeTablet) {
        menuWidth = 260;
      } else if (isTablet) {
        menuWidth = 240;
      } else if (isSmallTablet) {
        // Per tablet piccoli, usa una percentuale della larghezza schermo
        menuWidth = screenWidth * 0.75;
        if (menuWidth < 220) menuWidth = 220; // Larghezza minima
      } else if (isMobile) {
        // Per mobile, usa una percentuale maggiore ma non full screen
        menuWidth = screenWidth * 0.9;
        if (menuWidth < 200) menuWidth = 200; // Larghezza minima
      } else if (isVerySmall) {
        // Per schermi molto piccoli, usa quasi tutta la larghezza
        menuWidth = screenWidth * 0.95;
        if (menuWidth < 180) menuWidth = 180; // Larghezza minima
      } else if (isExtraSmall) {
        // Per schermi extra piccoli, usa tutta la larghezza disponibile
        menuWidth = screenWidth;
      } else {
        menuWidth = 240;
      }
    } else {
      // Quando è collassato, larghezza fissa per l'icona
      menuWidth = isExtraSmall ? 60 : 72;
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
                height: shouldBeExpanded
                    ? (isExtraSmall
                          ? 80
                          : isMobile
                          ? 100
                          : 120)
                    : (isExtraSmall
                          ? 50
                          : isMobile
                          ? 60
                          : 80),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(
                      isExtraSmall
                          ? 8
                          : isMobile
                          ? 12
                          : 16,
                    ),
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
                                    size: isExtraSmall
                                        ? 24
                                        : isMobile
                                        ? 28
                                        : 32,
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Menu del profilo
                                        PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.account_circle,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          onSelected: (value) {
                                            if (value == 'profile') {
                                              // Naviga al profilo
                                              Navigator.pushNamed(
                                                context,
                                                '/profile',
                                              );
                                            } else if (value == 'logout') {
                                              // Logout
                                              _showLogoutDialog(context, l10n);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'profile',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.person),
                                                  SizedBox(width: 8),
                                                  Text('Profilo'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'logout',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.logout),
                                                  SizedBox(width: 8),
                                                  Text('Logout'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (!isDesktop && !isVerySmall)
                                          IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: isMobile ? 18 : 20,
                                            ),
                                            onPressed: () =>
                                                onExpansionChanged(false),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isMobile ? 6 : 8),
                              Text(
                                l10n.getString('app_title'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isExtraSmall
                                      ? 14
                                      : isMobile
                                      ? 16
                                      : 18,
                                  fontWeight: FontWeight.bold,
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
                                    size: isMobile ? 20 : 22,
                                  ),
                                  onPressed: isVerySmall
                                      ? null
                                      : () => onExpansionChanged(true),
                                  tooltip: isVerySmall
                                      ? null
                                      : l10n.getString('open_menu'),
                                  padding: EdgeInsets.all(isMobile ? 1 : 2),
                                  constraints: BoxConstraints(
                                    minHeight: isMobile ? 28 : 32,
                                    minWidth: isMobile ? 28 : 32,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.verified_user,
                                color: Colors.white,
                                size: isMobile ? 12 : 14,
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
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  child: IconButton(
                    icon: Icon(
                      Icons.logout,
                      color: Colors.red[600],
                      size: isMobile ? 18 : 20,
                    ),
                    onPressed: () => _showLogoutDialog(context, l10n),
                    tooltip: l10n.getString('logout'),
                    padding: EdgeInsets.all(isMobile ? 4 : 8),
                    constraints: BoxConstraints(
                      minHeight: isMobile ? 32 : 40,
                      minWidth: isMobile ? 32 : 40,
                    ),
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
        // Rimosso menu Impostazioni
        {'icon': Icons.person, 'label': l10n.getString('profile'), 'index': 4},
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
        // Rimosso menu Impostazioni
        {'icon': Icons.person, 'label': l10n.getString('profile'), 'index': 3},
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
        // Rimosso menu Impostazioni
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isExtraSmall = screenWidth < 360;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isExtraSmall
            ? 4
            : isMobile
            ? 6
            : 8,
        vertical: isExtraSmall
            ? 1
            : isMobile
            ? 1
            : 2,
      ),
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
              horizontal: isExpanded
                  ? (isExtraSmall
                        ? 8
                        : isMobile
                        ? 12
                        : 16)
                  : (isExtraSmall ? 6 : 8),
              vertical: isExtraSmall
                  ? 8
                  : isMobile
                  ? 10
                  : 12,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.textSecondary,
                  size: isExtraSmall
                      ? 16
                      : isMobile
                      ? 18
                      : 20,
                ),
                if (isExpanded) ...[
                  SizedBox(
                    width: isExtraSmall
                        ? 8
                        : isMobile
                        ? 10
                        : 12,
                  ),
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
                        fontSize: isExtraSmall
                            ? 12
                            : isMobile
                            ? 13
                            : 14,
                      ),
                      overflow: TextOverflow.ellipsis,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isExtraSmall = screenWidth < 360;

    return Container(
      margin: EdgeInsets.all(
        isExtraSmall
            ? 4
            : isMobile
            ? 6
            : 8,
      ),
      child: Material(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showLogoutDialog(context, l10n),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isExtraSmall
                  ? 8
                  : isMobile
                  ? 12
                  : 16,
              vertical: isExtraSmall
                  ? 8
                  : isMobile
                  ? 10
                  : 12,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.red[600],
                  size: isExtraSmall
                      ? 16
                      : isMobile
                      ? 18
                      : 20,
                ),
                SizedBox(
                  width: isExtraSmall
                      ? 8
                      : isMobile
                      ? 10
                      : 12,
                ),
                Expanded(
                  child: Text(
                    l10n.getString('logout'),
                    style: TextStyle(
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                      fontSize: isExtraSmall
                          ? 12
                          : isMobile
                          ? 13
                          : 14,
                    ),
                    overflow: TextOverflow.ellipsis,
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

                // Force navigation immediately after logout
                if (context.mounted) {
                  try {
                    // Use pushNamedAndRemoveUntil to clear all routes and go to root
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                    print(
                      '✅ Global Menu: Navigation to public home successful',
                    );
                  } catch (navError) {
                    print('❌ Global Menu: Navigation error: $navError');
                    // Fallback: try to navigate after a delay
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (context.mounted) {
                        try {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (route) => false);
                          print(
                            '✅ Global Menu: Fallback navigation successful',
                          );
                        } catch (fallbackError) {
                          print(
                            '❌ Global Menu: Fallback navigation failed: $fallbackError',
                          );
                        }
                      }
                    });
                  }
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
