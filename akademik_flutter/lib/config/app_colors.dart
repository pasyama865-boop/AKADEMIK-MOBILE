import 'package:flutter/material.dart';

/// Konstanta warna terpusat untuk seluruh aplikasi.
///
/// Gunakan class ini di seluruh screen dan widget,
/// jangan hardcode warna secara langsung.
class AppColors {
  // Light Mode Colors (SaaS Modern)
  static const Color primaryLight = Color(0xFF2563EB); // Blue 600
  static const Color secondaryLight = Color(0xFF4F46E5); // Indigo 600
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500

  // Dark Mode Colors (SaaS Modern)
  static const Color primaryDark = Color(0xFF3B82F6); // Blue 500
  static const Color secondaryDark = Color(0xFF6366F1); // Indigo 500
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400

  // State Colors (Universal or slightly tweaked per mode, here we keep universal for badge/status)
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Fallback for legacy code
  static const Color primary = primaryLight;
  static const Color secondary = secondaryLight;
  static const Color background =
      backgroundDark; // Some screens heavily rely on this name for dark
  static const Color surface =
      surfaceDark; // Some screens heavily rely on this name for dark
  static const Color cardBackground = surfaceDark;
  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color divider = borderDark;
}
