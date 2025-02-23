import 'package:flutter/material.dart';

// Defining the Synthecure color palette using Material 3 standards
const Color synthecurePrimaryColor = Color(0xFF0693E3);
const Color synthecureSecondaryColor = Color(0xFF8ED1FC);
const Color synthecureSurfaceColor = Color(0xFFF0F0F0);
const Color synthecureAccentColor = Color(0xFFABB8C3);
const Color synthecureErrorColor = Color(0xFFE63946);
const Color synthecureSurfaceVariantColor =
    Color(0xFFF1F5F9); // Light gray for surfaces

// Updated ColorScheme using Material 3 standards
const ColorScheme synthecureColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: synthecurePrimaryColor,
  onPrimary: Colors.white,
  secondary: synthecureSecondaryColor,
  onSecondary: Colors.white,
  surface: Colors.white,
  onSurface: Colors.black,
  surfaceContainerHighest: synthecureSurfaceVariantColor,
  onSurfaceVariant: Colors.black,
  error: synthecureErrorColor,
  onError: Colors.white,
  outline: synthecureAccentColor,
  inverseSurface: Colors.black,
  onInverseSurface: Colors.white,
  inversePrimary:
      Color(0xFF1565C0), // A darker blue for contrast
);
