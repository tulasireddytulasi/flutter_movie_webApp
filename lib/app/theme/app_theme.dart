import 'package:flutter/material.dart';

/// Central theme configuration for Light and Dark modes
/// All UI components should use colors and typography from Theme.of(context)
class AppTheme {
  /// Primary brand colors
  static const Color _primaryDark = Color(0xFF89cfbe);
  static const Color _primaryLight = Color(0xFF1B2230);

  /// Dark theme surface colors
  static const Color _darkSurfaceDark = Color(0xFF1D1C1C);
  static const Color _darkSurfaceMedium = Color(0xFF3C3C3C);
  static const Color _darkSurfaceLight = Color(0xFF7C7C7C);
  static const Color _darkTextPrimary = Color(0xFFFFFFFF);
  static const Color _darkTextSecondary = Color(0xFFC4C4C4);

  /// Light theme surface colors
  static const Color _lightSurfaceDark = Color(0xFFFFFFFF);
  static const Color _lightSurfaceLight = Color(0xFFF7F7F7);
  static const Color _lightTextPrimary = Color(0xFF1D1C1C);
  static const Color _lightTextSecondary = Color(0xFF7C7C7C);

  /// Error color
  static const Color _errorColor = Color(0xFFEB1C1C);

  /// Get light theme
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: _primaryLight,
      scaffoldBackgroundColor: _lightSurfaceDark,
      colorScheme: ColorScheme.light(
        primary: _primaryLight,
        primaryContainer: _primaryLight.withValues(alpha: 0.1),
        secondary: _primaryDark,
        secondaryContainer: _primaryDark.withValues(alpha: 0.1),
        surface: _lightSurfaceDark,
        surfaceContainer: _lightSurfaceLight,
        surfaceContainerHighest: _lightSurfaceLight,
        onSurface: _lightTextPrimary,
        onSurfaceVariant: _lightTextSecondary,
        error: _errorColor,
        onError: Colors.white,
        errorContainer: _errorColor.withValues(alpha: 0.1),
      ),
      cardColor: _lightSurfaceDark,
      canvasColor: _lightSurfaceLight,
      dividerColor: Color(0xFFE4E4E4),
      disabledColor: Color(0xFFEFEFEF),

      // Text Theme
      textTheme: _buildTextTheme(
        primaryTextColor: _lightTextPrimary,
        secondaryTextColor: _lightTextSecondary,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurfaceDark,
        foregroundColor: _lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _lightTextPrimary,
          fontFamily: 'MontserratSemiBold',
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: _lightSurfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'MontserratSemiBold',
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryLight,
          side: BorderSide(color: _primaryLight),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'MontserratSemiBold',
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryLight,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'MontserratSemiBold',
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurfaceLight,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFFE4E4E4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFFE4E4E4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _errorColor, width: 2),
        ),
        labelStyle: TextStyle(
          color: _lightTextSecondary,
          fontFamily: 'MontserratRegular',
        ),
        hintStyle: TextStyle(
          color: _lightTextSecondary,
          fontFamily: 'MontserratRegular',
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightSurfaceDark,
        selectedItemColor: _primaryLight,
        unselectedItemColor: _lightTextSecondary,
        elevation: 8,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: _lightTextPrimary,
        size: 24,
      ),
    );
  }

  /// Get dark theme
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _primaryDark,
      scaffoldBackgroundColor: _darkSurfaceDark,
      colorScheme: ColorScheme.dark(
        primary: _primaryDark,
        primaryContainer: _primaryDark.withValues(alpha: 0.2),
        secondary: _primaryLight,
        secondaryContainer: _primaryLight.withValues(alpha: 0.2),
        surface: _darkSurfaceDark,
        surfaceContainer: _darkSurfaceMedium,
        surfaceContainerHighest: _darkSurfaceLight,
        onSurface: _darkTextPrimary,
        onSurfaceVariant: _darkTextSecondary,
        error: _errorColor,
        onError: _darkSurfaceDark,
        errorContainer: _errorColor.withValues(alpha: 0.2),
      ),
      cardColor: _darkSurfaceMedium,
      canvasColor: _darkSurfaceMedium,
      dividerColor: Color(0xFF545454),
      disabledColor: Color(0xFF505050),

      // Text Theme
      textTheme: _buildTextTheme(
        primaryTextColor: _darkTextPrimary,
        secondaryTextColor: _darkTextSecondary,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurfaceDark,
        foregroundColor: _darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
          fontFamily: 'MontserratSemiBold',
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: _darkSurfaceMedium,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: _darkSurfaceDark,
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'MontserratSemiBold',
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryDark,
          side: BorderSide(color: _primaryDark),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'MontserratSemiBold',
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryDark,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'MontserratSemiBold',
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurfaceLight.withValues(alpha: 0.1),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF545454)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF545454)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _errorColor, width: 2),
        ),
        labelStyle: TextStyle(
          color: _darkTextSecondary,
          fontFamily: 'MontserratRegular',
        ),
        hintStyle: TextStyle(
          color: _darkTextSecondary,
          fontFamily: 'MontserratRegular',
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkSurfaceDark,
        selectedItemColor: _primaryDark,
        unselectedItemColor: _darkTextSecondary,
        elevation: 8,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: _darkTextPrimary,
        size: 24,
      ),
    );
  }

  /// Build complete text theme
  static TextTheme _buildTextTheme({
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    const String regularFont = 'MontserratRegular';
    const String mediumFont = 'MontserratMedium';
    const String semiBoldFont = 'MontserratSemiBold';

    return TextTheme(
      // Display styles (large headlines)
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        fontFamily: semiBoldFont,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        fontFamily: semiBoldFont,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        fontFamily: semiBoldFont,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        fontFamily: semiBoldFont,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        fontFamily: semiBoldFont,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        fontFamily: semiBoldFont,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        fontFamily: semiBoldFont,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        fontFamily: mediumFont,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        fontFamily: mediumFont,
      ),

      // Body styles (main content text)
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
        fontFamily: regularFont,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
        fontFamily: regularFont,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
        fontFamily: regularFont,
      ),

      // Label styles (small, compact text)
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        fontFamily: mediumFont,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        fontFamily: mediumFont,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        fontFamily: mediumFont,
      ),
    );
  }
}
