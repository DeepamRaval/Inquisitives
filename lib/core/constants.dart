import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Safe-Scan Lite';

  // Risk Levels
  static const String riskSafe = 'Safe';
  static const String riskSuspicious = 'Suspicious';
  static const String riskDangerous = 'Dangerous';

  // Colors - Premium Dark Theme
  static const Color primaryColor = Color(0xFF6C63FF); // Electric Violet
  static const Color secondaryColor = Color(0xFF00E5FF); // Neon Cyan
  static const Color backgroundColor = Color(0xFF0A0E21); // Deep Navy/Black
  static const Color surfaceColor = Color(0xFF1D1E33); // Dark Surface
  static const Color successColor = Color(0xFF00C851);
  static const Color warningColor = Color(0xFFFFBB33);
  static const Color errorColor = Color(0xFFFF4444);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;

  // Messages
  static const String scanTooltip = 'Scan QR Code';
  static const String uploadTooltip = 'Upload from Gallery';
  static const String safeMessage = 'No obvious threats detected.';
  static const String suspiciousMessage = 'Proceed with caution.';
  static const String dangerousMessage = 'High risk detected! Do not open.';
}
