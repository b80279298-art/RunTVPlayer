import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0D0D0D);
  static const Color surfaceVariant = Color(0xFF1A1A1A);
  static const Color card = Color(0xFF111111);
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFF9D5CF6);
  static const Color purpleDark = Color(0xFF5B21B6);
  static const Color purpleAccent = Color(0xFFBB86FC);
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFE0E0E0);
  static const Color onSurfaceVariant = Color(0xFFAAAAAA);
  static const Color divider = Color(0xFF2A2A2A);
  static const Color error = Color(0xFFCF6679);
  static const Color border = Color(0xFF2D2D2D);
  static const Color pipBorder = Color(0xFF7C3AED);
  static const Color activeBorder = Color(0xFF9D5CF6);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      background: AppColors.background,
      surface: AppColors.surface,
      surfaceVariant: AppColors.surfaceVariant,
      primary: AppColors.purple,
      primaryContainer: AppColors.purpleDark,
      onPrimary: Colors.white,
      secondary: AppColors.purpleLight,
      onSecondary: Colors.white,
      tertiary: AppColors.purpleAccent,
      error: AppColors.error,
      onBackground: AppColors.onBackground,
      onSurface: AppColors.onSurface,
      outline: AppColors.border,
    ),
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.card,
    dividerColor: AppColors.divider,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.purpleDark.withOpacity(0.6),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: AppColors.purpleLight, size: 24);
        }
        return const IconThemeData(color: AppColors.onSurfaceVariant, size: 22);
      }),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(
            color: AppColors.purpleLight,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          );
        }
        return const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        );
      }),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.purpleLight,
      unselectedItemColor: AppColors.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardTheme(
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.purpleLight,
        side: const BorderSide(color: AppColors.purple),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.purpleLight,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.purple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
      labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
      floatingLabelStyle: const TextStyle(color: AppColors.purpleLight),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.purple,
      thumbColor: AppColors.purpleLight,
      inactiveTrackColor: AppColors.surfaceVariant,
      overlayColor: AppColors.purple.withOpacity(0.2),
      trackHeight: 3,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) return AppColors.purpleLight;
        return AppColors.onSurfaceVariant;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) return AppColors.purpleDark;
        return AppColors.surfaceVariant;
      }),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      iconColor: AppColors.purpleLight,
    ),
    iconTheme: const IconThemeData(color: AppColors.onSurface),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.w800),
      displayMedium: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.w700),
      headlineLarge: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: AppColors.onSurface),
      bodyMedium: TextStyle(color: AppColors.onSurface),
      bodySmall: TextStyle(color: AppColors.onSurfaceVariant),
      labelLarge: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.w600),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
