import 'package:flutter/material.dart';

class AppTheme {
  // Status colors (fixed, theme-independent)
  static const Color statusNormal = Color(0xFF2E9E5B);   // Deeper green
  static const Color statusWarning = Color(0xFFE8912A);  // Warm amber
  static const Color statusCritical = Color(0xFFD64545); // Softer red

  // Splash screen brand colors
  static const Color brandTeal = Color(0xFF00A294);      // Primary accent teal
  static const Color brandTealDark = Color(0xFF00897B);  // Deeper gradient anchor teal

  // Samsung One UI Premium Blue
  static const Color samsungBlue = Color(0xFF0072E5);
  
  // Samsung One UI Ecosystem Emerald Teal/Green
  static const Color samsungTealGreen = Color(0xFF00A294);

  // FIXED: Internal layout titles scaled back down to 20 so they don't overpower the home title
  static const _lightTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: brandTeal,
  );

  // CHANGED: Implemented a premium "Tealish White" color palette choice for Dark Mode headers
  static const _darkTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Color(0xFFE0F2F1), // Clean Tealish White
  );

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandTeal,
      primary: brandTeal,
      brightness: Brightness.light,
    ).copyWith(
      surface: const Color(0xFFFAFCFB),
      surfaceContainerHighest: const Color(0xFFEFF3F2),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF1F4F3),
      
      appBarTheme: const AppBarTheme(
        centerTitle: false, // Left-aligned left edge components matching requested style
        elevation: 0,
        backgroundColor: Color(0xFFF1F4F3),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: _lightTitleStyle,
        iconTheme: IconThemeData(color: brandTeal, size: 28), // Slightly enlarged global light drawer icons
      ),
      
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: brandTeal.withValues(alpha: 0.12), 
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: brandTeal, size: 26);
          }
          return const IconThemeData(color: Colors.grey);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: brandTeal, fontWeight: FontWeight.bold, fontSize: 13);
          }
          return const TextStyle(color: Colors.grey, fontSize: 12);
        }),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brandTeal;
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brandTeal;
          return Colors.grey.withValues(alpha: 0.6);
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: brandTeal,
        thumbColor: brandTeal,
        activeTickMarkColor: Colors.white70,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.black.withValues(alpha: 0.08),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandTeal,
      primary: brandTeal,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        titleTextStyle: _darkTitleStyle,
        iconTheme: IconThemeData(color: Color(0xFFE0F2F1), size: 28), // Tealish White custom scaled icon triggers
      ),
      
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: brandTeal.withValues(alpha: 0.25),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: brandTeal, size: 26);
          }
          return null;
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: brandTeal, fontWeight: FontWeight.bold);
          }
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brandTeal;
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brandTeal;
          return null;
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: brandTeal,
        thumbColor: brandTeal,
      ),
    );
  }
}
