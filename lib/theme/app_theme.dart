import 'package:flutter/material.dart';

class AppTheme {
  // Colori base enterprise eleganti
  static const Color _primaryBlack = Color(0xFF0A0A0A); // Nero molto scuro
  static const Color _darkCharcoal = Color(0xFF1A1A1A); // Grigio carbone scuro
  static const Color _charcoal = Color(0xFF2A2A2A); // Grigio carbone medio
  static const Color _mediumCharcoal = Color(
    0xFF3A3A3A,
  ); // Grigio carbone chiaro
  static const Color _lightCharcoal = Color(
    0xFF4A4A4A,
  ); // Grigio carbone molto chiaro

  // Accenti professionali (più sottili)
  static const Color _accentBlue = Color(0xFF2563EB); // Blu professionale
  static const Color _accentGreen = Color(0xFF059669); // Verde professionale
  static const Color _accentPurple = Color(0xFF7C3AED); // Viola professionale
  static const Color _accentOrange = Color(
    0xFFEA580C,
  ); // Arancione professionale

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

  // Colori aggiuntivi per compatibilità
  static Color get white => _pureWhite;
  static Color get primaryBlue => _accentBlue;
  static Color get successGreen => _accentGreen;
  static Color get errorRed => const Color(0xFFDC2626);
  static Color get warningOrange => _accentOrange;
  static Color get lightBlue => const Color(0xFF3B82F6);
  static Color get lightGrey => _lightGray;
  static Color get borderGrey => _lightGray;
  static Color get neutralGrey => _mediumGray;
  static Color get textTertiary => _mediumGray;
  static Color get textSecondary => _darkGray;
  static Color get secondaryBlue => const Color(0xFF1E40AF);
  static Color get infoBlue => const Color(0xFF0EA5E9);
  static Color get cardShadow => _primaryBlack.withValues(alpha: 0.1);

  // Stili di testo per compatibilità
  static TextStyle get title1 => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: _primaryBlack,
  );
  static TextStyle get title2 => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: _primaryBlack,
  );
  static TextStyle get title3 => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: _primaryBlack,
  );
  static TextStyle get headline2 => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: _primaryBlack,
  );
  static TextStyle get headline3 => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: _primaryBlack,
  );
  static TextStyle get body1 => TextStyle(fontSize: 16, color: _primaryBlack);
  static TextStyle get body2 => TextStyle(fontSize: 14, color: _primaryBlack);
  static TextStyle get caption => TextStyle(fontSize: 12, color: _primaryBlack);
  static TextStyle get button => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: _primaryBlack,
  );

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

  // Tema principale enterprise - Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: _accentBlue,
        secondary: _accentGreen,
        tertiary: _accentPurple,
        surface: _pureWhite,
        background: _offWhite,

        onPrimary: _pureWhite,
        onSecondary: _pureWhite,
        onTertiary: _pureWhite,
        onSurface: _primaryBlack,
        onBackground: _primaryBlack,
        surfaceTint: _pureWhite,
        error: _accentOrange,
        onError: _pureWhite,
      ),

      // Scaffold
      scaffoldBackgroundColor: _offWhite,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: _pureWhite,
        foregroundColor: _primaryBlack,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: _primaryBlack,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: _primaryBlack),
      ),

      // Card
      cardTheme: CardThemeData(
        color: _pureWhite,
        elevation: 2,
        shadowColor: _primaryBlack.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _lightGray, width: 1),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentBlue,
          foregroundColor: _pureWhite,
          elevation: 4,
          shadowColor: _accentBlue.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: TextStyle(
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: TextStyle(
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
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _lightGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _lightGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _accentBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _accentOrange, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: _darkGray,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: TextStyle(
          color: _mediumGray,
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
          color: _primaryBlack,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _primaryBlack,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _primaryBlack,
          letterSpacing: -0.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _primaryBlack,
          letterSpacing: -0.1,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _primaryBlack,
          letterSpacing: -0.1,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _primaryBlack,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _primaryBlack,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _primaryBlack,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _primaryBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _primaryBlack,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _primaryBlack,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: _darkGray,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _primaryBlack,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _primaryBlack,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _darkGray,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(color: _primaryBlack, size: 24),

      // Divider
      dividerTheme: const DividerThemeData(
        color: _lightGray,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _pureWhite,
        selectedItemColor: _accentBlue,
        unselectedItemColor: _darkGray,
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
        backgroundColor: _lightGray,
        selectedColor: _accentBlue.withValues(alpha: 0.1),
        disabledColor: _lightGray,
        labelStyle: TextStyle(
          color: _primaryBlack,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _lightGray, width: 1),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(_accentBlue),
        trackColor: WidgetStateProperty.all(_lightGray),
        trackOutlineColor: WidgetStateProperty.all(_lightGray),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(_accentBlue),
        checkColor: WidgetStateProperty.all(_pureWhite),
        side: const BorderSide(color: _lightGray, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(_accentBlue),
        overlayColor: WidgetStateProperty.all(
          _accentBlue.withValues(alpha: 0.1),
        ),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: _accentBlue,
        inactiveTrackColor: _lightGray,
        thumbColor: _accentBlue,
        overlayColor: _accentBlue.withValues(alpha: 0.1),
        valueIndicatorColor: _accentBlue,
        valueIndicatorTextStyle: TextStyle(
          color: _pureWhite,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _accentBlue,
        linearTrackColor: _lightGray,
        circularTrackColor: _lightGray,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: _pureWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: TextStyle(
          color: _primaryBlack,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(color: _primaryBlack, fontSize: 14),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _pureWhite,
        contentTextStyle: TextStyle(
          color: _primaryBlack,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _pureWhite,
        modalBackgroundColor: _pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Navigation Rail
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: _pureWhite,
        selectedIconTheme: IconThemeData(color: _accentBlue),
        unselectedIconTheme: IconThemeData(color: _darkGray),
        selectedLabelTextStyle: TextStyle(color: _accentBlue),
        unselectedLabelTextStyle: TextStyle(color: _darkGray),
        indicatorColor: _accentBlue,
      ),
    );
  }
}
