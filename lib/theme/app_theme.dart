import 'package:flutter/material.dart';

class AppTheme {
  // Modern Enterprise 2025 Color Palette - Light & Professional
  static const Color _primaryBlue = Color(0xFF0066CC); // Professional blue
  static const Color _secondaryBlue = Color(
    0xFF004499,
  ); // Darker blue for accents
  static const Color _lightBlue = Color(
    0xFFE6F3FF,
  ); // Very light blue background
  static const Color _accentBlue = Color(0xFF0080FF); // Bright accent blue

  // Success, Warning, Error colors
  static const Color _successGreen = Color(0xFF00A86B); // Professional green
  static const Color _warningOrange = Color(0xFFFF8C00); // Professional orange
  static const Color _errorRed = Color(0xFFE53E3E); // Professional red
  static const Color _infoBlue = Color(0xFF3182CE); // Info blue

  // Neutral grays - light and professional
  static const Color _pureWhite = Color(0xFFFFFFFF);
  static const Color _offWhite = Color(0xFFFAFBFC);
  static const Color _lightGray = Color(0xFFF1F5F9);
  static const Color _mediumGray = Color(0xFFE2E8F0);
  static const Color _borderGray = Color(0xFFCBD5E1);
  static const Color _textGray = Color(0xFF64748B);
  static const Color _darkGray = Color(0xFF334155);
  static const Color _textPrimary = Color(0xFF1E293B);

  // Additional professional colors
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _teal = Color(0xFF0891B2);
  static const Color _indigo = Color(0xFF4F46E5);

  // Modern gradients for 2025
  static const LinearGradient _primaryGradient = LinearGradient(
    colors: [_primaryBlue, _accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient _accentGradient = LinearGradient(
    colors: [_successGreen, _primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient _subtleGradient = LinearGradient(
    colors: [_lightGray, _mediumGray],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient _cardGradient = LinearGradient(
    colors: [_pureWhite, _offWhite],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Color getters for the new professional palette
  static Color get primaryBlue => _primaryBlue;
  static Color get secondaryBlue => _secondaryBlue;
  static Color get lightBlue => _lightBlue;
  static Color get accentBlue => _accentBlue;

  static Color get successGreen => _successGreen;
  static Color get warningOrange => _warningOrange;
  static Color get errorRed => _errorRed;
  static Color get infoBlue => _infoBlue;

  static Color get white => _pureWhite;
  static Color get offWhite => _offWhite;
  static Color get lightGray => _lightGray;
  static Color get mediumGray => _mediumGray;
  static Color get borderGray => _borderGray;
  static Color get textGray => _textGray;
  static Color get darkGray => _darkGray;
  static Color get textPrimary => _textPrimary;

  static Color get purple => _purple;
  static Color get teal => _teal;
  static Color get indigo => _indigo;

  // Legacy compatibility
  static Color get primaryBlack => _textPrimary;
  static Color get lightGrey => _lightGray;
  static Color get borderGrey => _borderGray;
  static Color get neutralGrey => _textGray;
  static Color get textTertiary => _textGray;
  static Color get textSecondary => _darkGray;
  static Color get cardShadow => _textPrimary.withValues(alpha: 0.08);

  // Modern text styles for 2025
  static TextStyle get title1 => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: _textPrimary,
    letterSpacing: -0.5,
  );
  static TextStyle get title2 => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: _textPrimary,
    letterSpacing: -0.3,
  );
  static TextStyle get title3 => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: _textPrimary,
    letterSpacing: -0.2,
  );
  static TextStyle get headline2 => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: _textPrimary,
    letterSpacing: -0.3,
  );
  static TextStyle get headline3 => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: _textPrimary,
    letterSpacing: -0.2,
  );
  static TextStyle get body1 => TextStyle(
    fontSize: 16,
    color: _textPrimary,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  static TextStyle get body2 => TextStyle(
    fontSize: 14,
    color: _textPrimary,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  static TextStyle get caption => TextStyle(
    fontSize: 12,
    color: _textGray,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );
  static TextStyle get button => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _pureWhite,
    letterSpacing: 0.2,
  );

  // Legacy color compatibility
  static Color get accentGreen => _successGreen;
  static Color get accentPurple => _purple;
  static Color get accentOrange => _warningOrange;

  static Color get pureWhite => _pureWhite;
  static Color get backgroundGrey => _offWhite;

  // Gradient getters
  static LinearGradient get primaryGradient => _primaryGradient;
  static LinearGradient get accentGradient => _accentGradient;
  static LinearGradient get subtleGradient => _subtleGradient;
  static LinearGradient get cardGradient => _cardGradient;

  // Modern Enterprise 2025 Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter', // Modern font
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: _primaryBlue,
        secondary: _successGreen,
        tertiary: _purple,
        surface: _pureWhite,
        surfaceContainerHighest: _lightGray,

        onPrimary: _pureWhite,
        onSecondary: _pureWhite,
        onTertiary: _pureWhite,
        onSurface: _textPrimary,
        surfaceTint: _pureWhite,
        error: _errorRed,
        onError: _pureWhite,
        outline: _borderGray,
        outlineVariant: _mediumGray,
      ),

      // Scaffold
      scaffoldBackgroundColor: _offWhite,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: _pureWhite,
        foregroundColor: _textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: _textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: _textPrimary, size: 24),
        actionsIconTheme: IconThemeData(color: _textPrimary, size: 24),
      ),

      // Card
      cardTheme: CardThemeData(
        color: _pureWhite,
        elevation: 0,
        shadowColor: _textPrimary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _borderGray, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: _pureWhite,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryBlue,
          side: const BorderSide(color: _primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorRed, width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: _textGray,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: const TextStyle(
          color: _textGray,
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
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
          letterSpacing: -0.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
          letterSpacing: -0.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
          letterSpacing: -0.1,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
          letterSpacing: -0.1,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
          letterSpacing: 0,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _textPrimary,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _textPrimary,
          letterSpacing: 0,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: _textGray,
          letterSpacing: 0.1,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _textPrimary,
          letterSpacing: 0,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _textPrimary,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _textGray,
          letterSpacing: 0.2,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: _textPrimary, size: 24),

      // Divider
      dividerTheme: const DividerThemeData(
        color: _borderGray,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _pureWhite,
        selectedItemColor: _primaryBlue,
        unselectedItemColor: _textGray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryBlue,
        foregroundColor: _pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: _lightBlue,
        selectedColor: _primaryBlue.withValues(alpha: 0.1),
        disabledColor: _lightGray,
        labelStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _borderGray, width: 1),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(_primaryBlue),
        trackColor: WidgetStateProperty.all(_lightGray),
        trackOutlineColor: WidgetStateProperty.all(_borderGray),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(_primaryBlue),
        checkColor: WidgetStateProperty.all(_pureWhite),
        side: const BorderSide(color: _borderGray, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(_primaryBlue),
        overlayColor: WidgetStateProperty.all(
          _primaryBlue.withValues(alpha: 0.1),
        ),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: _primaryBlue,
        inactiveTrackColor: _lightGray,
        thumbColor: _primaryBlue,
        overlayColor: _primaryBlue.withValues(alpha: 0.1),
        valueIndicatorColor: _primaryBlue,
        valueIndicatorTextStyle: const TextStyle(
          color: _pureWhite,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryBlue,
        linearTrackColor: _lightGray,
        circularTrackColor: _lightGray,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: _pureWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(color: _textPrimary, fontSize: 14),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _pureWhite,
        contentTextStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        selectedIconTheme: IconThemeData(color: _primaryBlue),
        unselectedIconTheme: IconThemeData(color: _textGray),
        selectedLabelTextStyle: TextStyle(color: _primaryBlue),
        unselectedLabelTextStyle: TextStyle(color: _textGray),
        indicatorColor: _primaryBlue,
      ),
    );
  }

  // Dark Theme Colors
  static const Color _darkPrimaryBlue = Color(
    0xFF4A9EFF,
  ); // Brighter blue for dark mode
  static const Color _darkSecondaryBlue = Color(0xFF3B82F6);
  static const Color _darkAccentBlue = Color(0xFF60A5FA);
  static const Color _darkSuccessGreen = Color(0xFF10B981);
  static const Color _darkWarningOrange = Color(0xFFF59E0B);
  static const Color _darkErrorRed = Color(0xFFEF4444);
  static const Color _darkInfoBlue = Color(0xFF3B82F6);

  // Dark mode neutral colors
  static const Color _darkBackground = Color(0xFF0F172A); // Very dark blue-gray
  static const Color _darkSurface = Color(0xFF1E293B); // Dark surface
  static const Color _darkSurfaceVariant = Color(
    0xFF334155,
  ); // Slightly lighter surface
  static const Color _darkBorder = Color(0xFF475569); // Dark border
  static const Color _darkTextPrimary = Color(0xFFF8FAFC); // Almost white
  static const Color _darkTextSecondary = Color(0xFFCBD5E1); // Light gray
  static const Color _darkTextTertiary = Color(0xFF94A3B8); // Medium gray

  // Dark mode gradients
  static const LinearGradient _darkPrimaryGradient = LinearGradient(
    colors: [_darkPrimaryBlue, _darkAccentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient _darkCardGradient = LinearGradient(
    colors: [_darkSurface, _darkSurfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimaryBlue,
        secondary: _darkSuccessGreen,
        tertiary: _purple,
        surface: _darkSurface,
        surfaceContainerHighest: _darkSurfaceVariant,
        background: _darkBackground,

        onPrimary: _darkBackground,
        onSecondary: _darkBackground,
        onTertiary: _darkBackground,
        onSurface: _darkTextPrimary,
        onBackground: _darkTextPrimary,
        surfaceTint: Colors.transparent,
        error: _darkErrorRed,
        onError: _darkBackground,
        outline: _darkBorder,
        outlineVariant: _darkSurfaceVariant,
      ),

      // Scaffold
      scaffoldBackgroundColor: _darkBackground,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: _darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: _darkTextPrimary, size: 24),
        actionsIconTheme: IconThemeData(color: _darkTextPrimary, size: 24),
      ),

      // Card
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shadowColor: _darkBackground.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _darkBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimaryBlue,
          foregroundColor: _darkBackground,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimaryBlue,
          side: const BorderSide(color: _darkPrimaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkPrimaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkErrorRed, width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: _darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: const TextStyle(
          color: _darkTextTertiary,
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
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: _darkTextPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: _darkTextPrimary,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: _darkTextPrimary,
          letterSpacing: -0.2,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
          letterSpacing: -0.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
          letterSpacing: -0.1,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
          letterSpacing: -0.1,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
          letterSpacing: 0,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _darkTextPrimary,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _darkTextSecondary,
          letterSpacing: 0,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: _darkTextTertiary,
          letterSpacing: 0.1,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _darkTextPrimary,
          letterSpacing: 0,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _darkTextPrimary,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _darkTextTertiary,
          letterSpacing: 0.2,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: _darkTextPrimary, size: 24),

      // Divider
      dividerTheme: const DividerThemeData(
        color: _darkBorder,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: _darkPrimaryBlue,
        unselectedItemColor: _darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkPrimaryBlue,
        foregroundColor: _darkBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: _darkSurfaceVariant,
        selectedColor: _darkPrimaryBlue.withValues(alpha: 0.2),
        disabledColor: _darkSurface,
        labelStyle: const TextStyle(
          color: _darkTextPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _darkBorder, width: 1),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(_darkPrimaryBlue),
        trackColor: WidgetStateProperty.all(_darkSurface),
        trackOutlineColor: WidgetStateProperty.all(_darkBorder),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(_darkPrimaryBlue),
        checkColor: WidgetStateProperty.all(_darkBackground),
        side: const BorderSide(color: _darkBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(_darkPrimaryBlue),
        overlayColor: WidgetStateProperty.all(
          _darkPrimaryBlue.withValues(alpha: 0.1),
        ),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: _darkPrimaryBlue,
        inactiveTrackColor: _darkSurface,
        thumbColor: _darkPrimaryBlue,
        overlayColor: _darkPrimaryBlue.withValues(alpha: 0.1),
        valueIndicatorColor: _darkPrimaryBlue,
        valueIndicatorTextStyle: const TextStyle(
          color: _darkBackground,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _darkPrimaryBlue,
        linearTrackColor: _darkSurface,
        circularTrackColor: _darkSurface,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: _darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          color: _darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: _darkTextSecondary,
          fontSize: 14,
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkSurface,
        contentTextStyle: const TextStyle(
          color: _darkTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _darkSurface,
        modalBackgroundColor: _darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Navigation Rail
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: _darkSurface,
        selectedIconTheme: IconThemeData(color: _darkPrimaryBlue),
        unselectedIconTheme: IconThemeData(color: _darkTextTertiary),
        selectedLabelTextStyle: TextStyle(color: _darkPrimaryBlue),
        unselectedLabelTextStyle: TextStyle(color: _darkTextTertiary),
        indicatorColor: _darkPrimaryBlue,
      ),
    );
  }
}
