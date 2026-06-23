import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  AppText._();

  /// Display / headings — Cormorant Garamond serif (loaded from Google Fonts at runtime).
  static TextStyle display({
    double size = 32,
    FontWeight weight = FontWeight.w500,
    double height = 1.1,
    Color? color,
  }) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color ?? AppColors.ink,
      );

  /// Body / UI — Inter.
  static TextStyle body({
    double size = 15,
    FontWeight weight = FontWeight.w400,
    double height = 1.5,
    Color? color,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color ?? AppColors.ink,
      );

  static TextStyle label({
    double size = 11,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: 1.2,
        letterSpacing: 0.6,
        color: color ?? AppColors.inkMute,
      );

  static TextStyle link({double size = 14, Color? color}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.accent,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.accent,
      );
}
