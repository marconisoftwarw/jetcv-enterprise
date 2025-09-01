import 'package:flutter/material.dart';

class AppTheme {
  // Colori base enterprise eleganti
  static const Color _primaryBlack = Color(0xFF0A0A0A);      // Nero molto scuro
  static const Color _darkCharcoal = Color(0xFF1A1A1A);      // Grigio carbone scuro
  static const Color _charcoal = Color(0xFF2A2A2A);          // Grigio carbone medio
  static const Color _mediumCharcoal = Color(0xFF3A3A3A);    // Grigio carbone chiaro
  static const Color _lightCharcoal = Color(0xFF4A4A4A);     // Grigio carbone molto chiaro
  
  // Accenti professionali (più sottili)
  static const Color _accentBlue = Color(0xFF2563EB);        // Blu professionale
  static const Color _accentGreen = Color(0xFF059669);       // Verde professionale
  static const Color _accentPurple = Color(0xFF7C3AED);      // Viola professionale
  static const Color _accentOrange = Color(0xFFEA580C);      // Arancione professionale
  
  // Tipografia enterprise
  static const Color _pureWhite = Color(0xFFFFFFFF);
  static const Color _offWhite = Color(0xFFF8FAFC);
  static const Color _lightGray = Color(0xFFE2E8F0);
  static const Color _mediumGray = Color(0xFF94A3B8);
  static const Color _darkGray = Color(0xFF475569);
  
  // Sfumature per glassmorphism
  static const Color _glassDark = Color(0xFF1E293B);
  static const Color _glassMedium = Color(0xFF334155);
  static const Color _glassLight = Color(0xFF475569);

  // Gradienti professionali
  static const LinearGradient _primaryGradient = LinearGradient(
    colors: [_accentBlue, _accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient _accentGradient = LinearGradient(
    colors: [_accentGreen, _accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient _subtleGradient = LinearGradient(
    colors: [_charcoal, _mediumCharcoal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Getters per i colori
  static Color get primaryBlack => _primaryBlack;
  static Color get darkCharcoal => _darkCharcoal;
  static Color get charcoal => _charcoal;
  static Color get mediumCharcoal => _mediumCharcoal;
  static Color get lightCharcoal => _lightCharcoal;
  
  static Color get accentBlue => _accentBlue;
  static Color get accentGreen => _accentGreen;
  static Color get accentPurple => _accentPurple;
  static Color get accentOrange => _accentOrange;
  
  static Color get pureWhite => _pureWhite;
  static Color get offWhite => _offWhite;
  static Color get lightGray => _lightGray;
  static Color get mediumGray => _mediumGray;
  static Color get darkGray => _darkGray;
  
  static Color get glassDark => _glassDark;
  static Color get glassMedium => _glassMedium;
  static Color get glassLight => _glassLight;
  
  static LinearGradient get primaryGradient => _primaryGradient;
  static LinearGradient get accentGradient => _accentGradient;
  static LinearGradient get subtleGradient => _subtleGradient;

  // Tema principale enterprise
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: _accentBlue,
        secondary: _accentGreen,
        tertiary: _accentPurple,
        surface: _darkCharcoal,

        onPrimary: _pureWhite,
        onSecondary: _pureWhite,
        onTertiary: _pureWhite,
        onSurface: _offWhite,
        surfaceTint: _primaryBlack,
        error: _accentOrange,
        onError: _pureWhite,
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
        iconTheme: IconThemeData(color: _accentBlue),
      ),

      // Card
      cardTheme: CardThemeData(
        color: _glassMedium,
        elevation: 4,
        shadowColor: _accentBlue.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _accentBlue.withValues(alpha: 0.1), width: 1),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentBlue,
          foregroundColor: _pureWhite,
          elevation: 4,
          shadowColor: _accentBlue.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _accentBlue,
          side: const BorderSide(color: _accentBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accentBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _glassLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _mediumCharcoal, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _mediumCharcoal, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _accentBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _accentOrange, width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: _mediumGray,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: const TextStyle(
          color: _darkGray,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: _offWhite,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _offWhite,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _offWhite,
          letterSpacing: -0.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _offWhite,
          letterSpacing: -0.1,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _offWhite,
          letterSpacing: -0.1,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _offWhite,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _offWhite,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _offWhite,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _offWhite,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _lightGray,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _lightGray,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: _mediumGray,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _offWhite,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _offWhite,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _mediumGray,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: _accentBlue, size: 24),

      // Divider
      dividerTheme: const DividerThemeData(
        color: _mediumCharcoal,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _glassDark,
        selectedItemColor: _accentBlue,
        unselectedItemColor: _mediumGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _accentBlue,
        foregroundColor: _pureWhite,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: _glassMedium,
        selectedColor: _accentBlue.withValues(alpha: 0.1),
        disabledColor: _mediumCharcoal,
        labelStyle: const TextStyle(
          color: _offWhite,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _accentBlue.withValues(alpha: 0.2), width: 1),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(_accentBlue),
        trackColor: WidgetStateProperty.all(_glassLight),
        trackOutlineColor: WidgetStateProperty.all(_mediumCharcoal),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(_accentBlue),
        checkColor: WidgetStateProperty.all(_pureWhite),
        side: const BorderSide(color: _mediumCharcoal, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(_accentBlue),
        overlayColor: WidgetStateProperty.all(_accentBlue.withValues(alpha: 0.1)),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: _accentBlue,
        inactiveTrackColor: _glassLight,
        thumbColor: _accentBlue,
        overlayColor: _accentBlue.withValues(alpha: 0.1),
        valueIndicatorColor: _accentBlue,
        valueIndicatorTextStyle: const TextStyle(
          color: _pureWhite,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _accentBlue,
        linearTrackColor: _glassLight,
        circularTrackColor: _glassLight,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: _glassDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: const TextStyle(
          color: _offWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: _lightGray,
          fontSize: 14,
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _glassDark,
        contentTextStyle: const TextStyle(
          color: _offWhite,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _glassDark,
        modalBackgroundColor: _glassDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Navigation Rail
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: _glassDark,
        selectedIconTheme: IconThemeData(color: _accentBlue),
        unselectedIconTheme: IconThemeData(color: _mediumGray),
        selectedLabelTextStyle: TextStyle(color: _accentBlue),
        unselectedLabelTextStyle: TextStyle(color: _mediumGray),
        indicatorColor: _accentBlue,
      ),
    );
  }
}
