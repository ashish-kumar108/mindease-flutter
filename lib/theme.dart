import 'package:flutter/material.dart';

// Centralized theme for the app using a teal -> indigo palette
const Color _seedTeal = Color(0xFF11998E);
const Color _seedIndigo = Color(0xFF0575E6);

// Common gradients used across the app
const LinearGradient primaryGradient = LinearGradient(
  colors: [_seedTeal, _seedIndigo],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient purpleBlueGradient = LinearGradient(
  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient greenGradient = LinearGradient(
  colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient orangeGradient = LinearGradient(
  colors: [Color(0xFFF2994A), Color(0xFFF2C94C)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient pinkGradient = LinearGradient(
  colors: [Color(0xFFB24592), Color(0xFFF15F79)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

ThemeData buildAppTheme() {
  // Build from seed then override specific fields via copyWith to avoid
  // passing unsupported named parameters to fromSeed.
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _seedIndigo,
    brightness: Brightness.light,
  ).copyWith(
    primary: _seedIndigo,
    secondary: _seedTeal,
    surface: const Color(0xFFF3FBFA),
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: Typography.material2021().englishLike.copyWith(
      bodyLarge: const TextStyle(color: Colors.black87),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _seedIndigo,
      foregroundColor: Colors.white,
    ),
    bottomAppBarTheme: BottomAppBarThemeData(
      color: Colors.white.withAlpha(229),
      elevation: 8,
    ),
  );
}
