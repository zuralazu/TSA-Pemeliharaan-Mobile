// Sentralisasi semua warna aplikasi agar konsisten di seluruh codebase.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand / Primary 
  static const Color primary       = Color(0xFF0A6EBD);
  static const Color primaryLight  = Color(0xFF3B9FE8);
  static const Color primaryDark   = Color(0xFF063970);

  // ── Accent
  static const Color accent        = Color(0xFF00D4AA);

  // ── Status
  static const Color good          = Color(0xFF00C897);
  static const Color bad           = Color(0xFFFF4C6A);
  static const Color warning       = Color(0xFFFF9500);
  static const Color info          = Color(0xFF3B9FE8);

  // ── APAR Accent 
  static const Color aparAccent    = Color(0xFFE04B3E);
  static const Color aparAccentSoft= Color(0xFFFDEDEB);

  // ── Hydrant Accent 
  static const Color hydrantAccent     = Color(0xFF1E6FBF);
  static const Color hydrantAccentSoft = Color(0xFFE9F1FA);

  // ── Background 
  static const Color bgPage        = Color(0xFFF0F4F8);
  static const Color bgCard        = Color(0xFFFFFFFF);
  static const Color bgInput       = Color(0xFFF8FAFC);

  // ── Text──
  static const Color textPrimary   = Color(0xFF0F1B2D);
  static const Color textSecondary = Color(0xFF637083);
  static const Color textHint      = Color(0xFF94A3B8);

  // ── Border / Divider 
  static const Color divider       = Color(0xFFE8EEF4);
  static const Color border        = Color(0xFFEDF0F5);
  static const Color borderInput   = Color(0xFFE2E8F0);

  // ── Auth (onboarding, login, register)
  static const Color authBlue      = Color(0xFF1976D2);
  static const Color authBlueLight = Color(0xFF42A5F5);

  // ── Blue Shades (untuk gradient dashboard)
  static final Color blueStart     = Colors.blue.shade700;
  static final Color blueEnd       = Colors.blue.shade900;
}
