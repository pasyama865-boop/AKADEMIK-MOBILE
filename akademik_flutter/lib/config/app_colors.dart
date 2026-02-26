import 'package:flutter/material.dart';

/// Konstanta warna terpusat untuk seluruh aplikasi.
///
/// Gunakan class ini di seluruh screen dan widget,
/// jangan hardcode warna secara langsung.
class AppColors {
  // Warna Background
  static const Color background = Color(0xFF111827);
  static const Color surface = Color(0xFF1F2937);

  // Warna Aksen
  static const Color primary = Colors.amber;
  static const Color primaryDark = Color(0xFFF59E0B);

  // Warna Teks
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;

  // Warna Status
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color info = Colors.blue;

  // Warna Komponen
  static const Color cardBackground = Color(0xFF1F2937);
  static const Color divider = Colors.grey;
}
