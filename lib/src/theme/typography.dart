import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Defining modern TextTheme using Google Fonts
final TextTheme synthecureTextTheme = TextTheme(
  displayLarge: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black),
  displayMedium: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
  displaySmall: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.black),
  
  headlineLarge: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
  headlineMedium: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
  headlineSmall: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
  
  titleLarge: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
  titleMedium: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
  titleSmall: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
  
  bodyLarge: GoogleFonts.roboto(fontSize: 16, color: Colors.black),
  bodyMedium: GoogleFonts.roboto(fontSize: 14, color: Colors.black),
  bodySmall: GoogleFonts.roboto(fontSize: 12, color: Colors.black),

  labelLarge: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
  labelMedium: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
  labelSmall: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
);
