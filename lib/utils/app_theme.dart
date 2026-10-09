import 'package:flutter/material.dart';

class AppTheme {
  static const Color navyPrimary = Color(0xFF0F2537);
  static const Color customsBlue = Color(0xFF1565C0);
  static const Color customsBlueDark = Color(0xFF0D47A1);
  static const Color customsGold = Color(0xFFD97706);
  static const Color customsGoldLight = Color(0xFFFBBF24);
  static const Color securityGreen = Color(0xFF10B981);
  static const Color securityGreenLight = Color(0xFFD1FAE5);
  static const Color tamperRed = Color(0xFFEF4444);
  static const Color tamperRedLight = Color(0xFFFEE2E2);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningAmberLight = Color(0xFFFEF3C7);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);

  // Role-Specific Theme Accents & Gradients
  static const List<Color> driverGradient = [
    Color(0xFF091E34),
    Color(0xFF0C2D48),
    Color(0xFF0284C7),
  ];
  static const Color driverAccent = Color(0xFF0284C7);
  static const Color driverPillBg = Color(0xFFEFF6FF);

  static const List<Color> inspectorGradient = [
    Color(0xFF061F2D),
    Color(0xFF0A343D),
    Color(0xFF0F766E),
  ];
  static const Color inspectorAccent = Color(0xFF0D9488);
  static const Color inspectorPillBg = Color(0xFFF0FDF4);

  static const List<Color> ownerGradient = [
    Color(0xFF0B172E),
    Color(0xFF1B2A56),
    Color(0xFF2563EB),
  ];
  static const Color ownerAccent = Color(0xFF2563EB);
  static const Color ownerPillBg = Color(0xFFEEF2FF);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: slate50,
    colorScheme: ColorScheme.fromSeed(
      seedColor: customsBlue,
      primary: customsBlue,
      onPrimary: Colors.white,
      secondary: customsGold,
      surface: Colors.white,
      onSurface: slate800,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: navyPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
        color: Colors.white,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: customsBlue.withValues(alpha: 0.12),
      surfaceTintColor: Colors.white,
      elevation: 8,
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: customsBlue,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: customsBlue, size: 24);
        }
        return const IconThemeData(color: Colors.black54, size: 22);
      }),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: slate200, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: slate200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: customsBlue, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: customsBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    ),
  );
}