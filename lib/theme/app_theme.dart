import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Palette colori futuristiche 2025
  static const Color _primaryBlack = Color(0xFF000000);
  static const Color _secondaryBlack = Color(0xFF0A0A0A);
  static const Color _darkGray = Color(0xFF1A1A1A);
  static const Color _mediumGray = Color(0xFF2A2A2A);
  static const Color _lightGray = Color(0xFF3A3A3A);

  // Neon accents
  static const Color _neonGreen = Color(0xFF00FF88);
  static const Color _neonBlue = Color(0xFF00D4FF);
  static const Color _neonPurple = Color(0xFF8B5CF6);
  static const Color _neonOrange = Color(0xFFFF6B35);
  static const Color _neonPink = Color(0xFFFF0080);

  // Typography
  static const Color _pureWhite = Color(0xFFFFFFFF);
  static const Color _offWhite = Color(0xFFE0E0E0);
  static const Color _lightGrayText = Color(0xFFB0B0B0);
  static const Color _mediumGrayText = Color(0xFF808080);

  // Glassmorphism
  static const Color _glassDark = Color(0x80000000);
  static const Color _glassMedium = Color(0x40000000);
  static const Color _glassLight = Color(0x20000000);

  // Gradients
  static const LinearGradient _neonGradient = LinearGradient(
    colors: [_neonGreen, _neonBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient _purpleGradient = LinearGradient(
    colors: [_neonPurple, _neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient _orangeGradient = LinearGradient(
    colors: [_neonOrange, _neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: _neonGreen,
        secondary: _neonBlue,
        tertiary: _neonPurple,
        surface: _darkGray,
        onPrimary: _primaryBlack,
        onSecondary: _primaryBlack,
        onTertiary: _primaryBlack,
        onSurface: _offWhite,
        surfaceTint: _primaryBlack,
        error: _neonOrange,
        onError: _primaryBlack,
      ),

      // Scaffold
      scaffoldBackgroundColor: _primaryBlack,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: _glassDark,
        foregroundColor: _offWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: _offWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: _neonGreen),
      ),

      // Card
      cardTheme: CardThemeData(
        color: _glassMedium,
        elevation: 8,
        shadowColor: _neonGreen.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _neonGreen.withValues(alpha: 0.2), width: 1),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _neonGreen,
          foregroundColor: _primaryBlack,
          elevation: 8,
          shadowColor: _neonGreen.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _neonGreen,
          side: const BorderSide(color: _neonGreen, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _neonBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _glassLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _lightGray.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _neonGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _neonOrange, width: 2),
        ),
        labelStyle: const TextStyle(
          color: _lightGrayText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: const TextStyle(
          color: _mediumGrayText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: _offWhite,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: _offWhite,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          color: _offWhite,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        headlineLarge: TextStyle(
          color: _offWhite,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          color: _offWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          color: _offWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          color: _offWhite,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          color: _offWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          color: _offWhite,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          color: _lightGrayText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          color: _lightGrayText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          color: _mediumGrayText,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          color: _offWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          color: _lightGrayText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          color: _mediumGrayText,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: _neonGreen, size: 24),

      // Divider
      dividerTheme: const DividerThemeData(
        color: _lightGray,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _glassDark,
        selectedItemColor: _neonGreen,
        unselectedItemColor: _lightGrayText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _neonGreen,
        foregroundColor: _primaryBlack,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: _glassMedium,
        selectedColor: _neonGreen.withValues(alpha: 0.2),
        disabledColor: _mediumGray,
        labelStyle: const TextStyle(
          color: _offWhite,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _neonGreen.withValues(alpha: 0.3), width: 1),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _neonGreen;
          }
          return _lightGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _neonGreen.withValues(alpha: 0.3);
          }
          return _mediumGray;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _neonGreen;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(_primaryBlack),
        side: const BorderSide(color: _lightGray, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _neonGreen;
          }
          return _lightGray;
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: _neonGreen,
        inactiveTrackColor: _mediumGray,
        thumbColor: _neonGreen,
        overlayColor: _neonGreen.withValues(alpha: 0.2),
        valueIndicatorColor: _neonGreen,
        valueIndicatorTextStyle: const TextStyle(
          color: _primaryBlack,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _neonGreen,
        linearTrackColor: _mediumGray,
        circularTrackColor: _mediumGray,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: _darkGray,
        elevation: 16,
        shadowColor: _neonGreen.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _neonGreen.withValues(alpha: 0.2), width: 1),
        ),
        titleTextStyle: const TextStyle(
          color: _offWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        contentTextStyle: const TextStyle(
          color: _lightGrayText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _glassDark,
        contentTextStyle: const TextStyle(
          color: _offWhite,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _darkGray,
        modalBackgroundColor: _darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Navigation Rail
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: _glassDark,
        selectedIconTheme: IconThemeData(color: _neonGreen),
        unselectedIconTheme: IconThemeData(color: _lightGrayText),
        selectedLabelTextStyle: TextStyle(color: _neonGreen),
        unselectedLabelTextStyle: TextStyle(color: _lightGrayText),
      ),
    );
  }

  // Gradients statici per uso diretto
  static const neonGradient = _neonGradient;
  static const purpleGradient = _purpleGradient;
  static const orangeGradient = _orangeGradient;

  // Colori statici per uso diretto
  static const primaryBlack = _primaryBlack;
  static const secondaryBlack = _secondaryBlack;
  static const darkGray = _darkGray;
  static const mediumGray = _mediumGray;
  static const lightGray = _lightGray;
  static const neonGreen = _neonGreen;
  static const neonBlue = _neonBlue;
  static const neonPurple = _neonPurple;
  static const neonOrange = _neonOrange;
  static const neonPink = _neonPink;
  static const pureWhite = _pureWhite;
  static const offWhite = _offWhite;
  static const lightGrayText = _lightGrayText;
  static const mediumGrayText = _mediumGrayText;
  static const glassDark = _glassDark;
  static const glassMedium = _glassMedium;
  static const glassLight = _glassLight;
}
