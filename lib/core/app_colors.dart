import 'package:flutter/material.dart';

/// Centralized color palette for Litera app with Green Aesthetic.
abstract final class AppColors {
  // ── Brand (The Soul of Litera) ──────────────────────────────────────────────
  static const Color emerald = Color(0xFF10B981);
  static const Color forest = Color(0xFF065F46);
  static const Color softGreen = Color(0xFFD1FAE5);
  static const Color primary = Color(0xFF059669); // Emerald Green
  static const Color primaryDark = Color(0xFF064E3B);
  static const Color primaryLight = Color(0xFF34D399);
  
  // ── Accents ─────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFFACC15); // Golden yellow for ratings
  static const Color star = Color(0xFFFACC15);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ── Light Theme (Soft Green Tint Backgrounds) ────────────────────────────────
  static const Color surfaceLight = Color(0xFFF0FDF4); // Very soft green tint
  static const Color cardLight = Colors.white;
  static const Color backgroundLight = Color(0xFFF8FAF9); // Off-white green tint
  static const Color scaffoldLight = Color(0xFFF8FAF9);

  // ── Dark Theme (Deep Forest Green Backgrounds) ───────────────────────────────
  static const Color backgroundDark = Color(0xFF061A13); // Deep forest tint
  static const Color cardDark = Color(0xFF0D251D); // Dark emerald surface
  static const Color surfaceDark = Color(0xFF0D251D);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textOnPrimary = Colors.white;

  // ── Bottom Nav ──────────────────────────────────────────────────────────────
  static const Color navBackground = Color(0xFF064E3B); // Dark Forest for Light mode
  static const Color navBackgroundDark = Color(0xFF042F2E);
  
  // ── Misc ───────────────────────────────────────────────────────────────────
  static const Color divider = Color(0x14000000);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);
  static const Color shimmerBaseDark = Color(0xFF162E26);
  static const Color shimmerHighlightDark = Color(0xFF1E3A31);
}
