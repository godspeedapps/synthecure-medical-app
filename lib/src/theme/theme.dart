import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

// Updated ThemeData for Material 3 compliance
final ThemeData synthecureTheme = ThemeData(
 
  colorScheme: synthecureColorScheme,
  useMaterial3: true, // Enabling Material 3 features
  textTheme: synthecureTextTheme,
  scaffoldBackgroundColor: synthecureSurfaceColor,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.white,
    titleTextStyle: synthecureTextTheme.titleMedium,
    scrolledUnderElevation: 0, // Prevents color change on scroll
    surfaceTintColor: Colors.transparent, // Prevents the subtle tint effect
  ),
  
);
