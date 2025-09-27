import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_type_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'global_hamburger_menu.dart';
import 'mobile_top_bar.dart';

/// Responsive layout wrapper that provides consistent mobile-responsive behavior
/// across all screens in the app
class ResponsiveLayout extends StatefulWidget {
  final Widget child;
  final bool showMenu;
  final int? selectedIndex;
  final Function(int)? onDestinationSelected;
  final String? title;
  final List<Widget>? actions;
  final bool hideAppBar;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.showMenu = true,
    this.selectedIndex,
    this.onDestinationSelected,
    this.title,
    this.actions,
    this.hideAppBar =
        true, // Cambiato da false a true per nascondere l'AppBar di default
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  bool _isMenuExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(isMobile, isTablet, isDesktop),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
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
            ),
            child: _buildBody(isMobile, isTablet, isDesktop, authProvider),
          ),
        );
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    if (widget.hideAppBar) return null;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: widget.showMenu && !isDesktop
          ? IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.black,
                size: isMobile ? 24 : 28,
              ),
              onPressed: () {
                setState(() {
                  _isMenuExpanded = !_isMenuExpanded;
                });
              },
              tooltip: 'Apri menu',
            )
          : null,
      title: widget.title != null
          ? Text(
              widget.title!,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: isMobile
                    ? 18
                    : isTablet
                    ? 20
                    : 22,
              ),
            )
          : null,
      actions: widget.actions ?? [],
      centerTitle: isMobile || isTablet,
    );
  }

  Widget _buildBody(
    bool isMobile,
    bool isTablet,
    bool isDesktop,
    AuthProvider authProvider,
  ) {
    if (!widget.showMenu) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: widget.child,
      );
    }

    // Desktop layout - sidebar sempre visibile
    if (isDesktop) {
      return Row(
        children: [
          _buildNavigationMenu(isMobile, isTablet, isDesktop, authProvider),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: widget.child,
            ),
          ),
        ],
      );
    }

    // Mobile/Tablet layout - menu hamburger con barra superiore dedicata
    return Column(
      children: [
        // Barra superiore dedicata per mobile e tablet
        if (!isDesktop)
          MobileTopBar(
            onMenuTap: widget.showMenu
                ? () {
                    setState(() {
                      _isMenuExpanded = !_isMenuExpanded;
                    });
                  }
                : null,
            isMenuExpanded: _isMenuExpanded,
            title: widget.title,
          ),

        // Contenuto principale con menu
        Expanded(
          child: Stack(
            children: [
              // Main content
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: widget.child,
              ),

              // Navigation Menu - slide in from left on mobile
              if (_isMenuExpanded)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: isMobile ? 280 : 320,
                    child: _buildNavigationMenu(
                      isMobile,
                      isTablet,
                      isDesktop,
                      authProvider,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationMenu(
    bool isMobile,
    bool isTablet,
    bool isDesktop,
    AuthProvider authProvider,
  ) {
    double menuWidth;
    if (isDesktop) {
      menuWidth = 280;
    } else if (isTablet) {
      menuWidth = 320;
    } else {
      menuWidth = 280; // Mobile expanded width
    }

    return Container(
      width: menuWidth,
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
        border: isDesktop
            ? Border(
                right: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDesktop ? 0.1 : 0.3),
            blurRadius: isDesktop ? 12 : 20,
            spreadRadius: 0,
            offset: Offset(isDesktop ? 4 : 6, 0),
          ),
        ],
      ),
      child: GlobalHamburgerMenu(
        selectedIndex: widget.selectedIndex ?? 0,
        onDestinationSelected: (index) {
          // Chiudi il menu su mobile/tablet dopo la selezione
          if (!isDesktop) {
            setState(() {
              _isMenuExpanded = false;
            });
          }
          // Esegui la callback originale
          if (widget.onDestinationSelected != null) {
            widget.onDestinationSelected!(index);
          }
        },
        isExpanded: _isMenuExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isMenuExpanded = expanded;
          });
        },
        context: context,
        userType: authProvider.userType,
      ),
    );
  }
}

/// Responsive breakpoint utilities
class ResponsiveBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1200;
  static const double desktop = 1440;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }

  static bool isSmallMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 480;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }
}

/// Responsive padding utilities
class ResponsivePadding {
  static EdgeInsets screen(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);

    if (isMobile) {
      return const EdgeInsets.all(16);
    } else if (isTablet) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  static EdgeInsets card(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    if (isMobile) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(20);
    }
  }

  static EdgeInsets section(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    if (isMobile) {
      return const EdgeInsets.symmetric(vertical: 16);
    } else {
      return const EdgeInsets.symmetric(vertical: 24);
    }
  }
}

/// Responsive text utilities
class ResponsiveTextStyles {
  static TextStyle? titleLarge(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    return Theme.of(context).textTheme.titleLarge?.copyWith(
      fontSize: isMobile ? 20 : 24,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle? titleMedium(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    return Theme.of(context).textTheme.titleMedium?.copyWith(
      fontSize: isMobile ? 16 : 18,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle? bodyLarge(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    return Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontSize: isMobile ? 14 : 16);
  }

  static TextStyle? bodyMedium(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    return Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontSize: isMobile ? 12 : 14);
  }
}

/// Responsive grid utilities
class ResponsiveGrid {
  static int getColumns(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);

    if (isMobile) {
      return 1;
    } else if (isTablet) {
      return 2;
    } else {
      return 3;
    }
  }

  static double getChildAspectRatio(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    if (isMobile) {
      return 1.2;
    } else {
      return 1.0;
    }
  }

  static double getCrossAxisSpacing(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    if (isMobile) {
      return 12;
    } else {
      return 16;
    }
  }

  static double getMainAxisSpacing(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    if (isMobile) {
      return 12;
    } else {
      return 16;
    }
  }
}

/// Responsive container utilities
class ResponsiveContainer {
  static double getMaxWidth(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);

    if (isMobile) {
      return double.infinity;
    } else if (isTablet) {
      return 600;
    } else {
      return 800;
    }
  }

  static EdgeInsets getPadding(BuildContext context) {
    return ResponsivePadding.screen(context);
  }

  static BorderRadius getBorderRadius(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    if (isMobile) {
      return BorderRadius.circular(12);
    } else {
      return BorderRadius.circular(16);
    }
  }
}

/// Responsive text widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextType textType;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textType = TextType.bodyMedium,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle? responsiveStyle;

    switch (textType) {
      case TextType.titleLarge:
        responsiveStyle = ResponsiveTextStyles.titleLarge(context);
        break;
      case TextType.titleMedium:
        responsiveStyle = ResponsiveTextStyles.titleMedium(context);
        break;
      case TextType.bodyLarge:
        responsiveStyle = ResponsiveTextStyles.bodyLarge(context);
        break;
      case TextType.bodyMedium:
        responsiveStyle = ResponsiveTextStyles.bodyMedium(context);
        break;
    }

    return Text(
      text,
      style: style ?? responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

enum TextType { titleLarge, titleMedium, bodyLarge, bodyMedium }
