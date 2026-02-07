import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Safe-Scan Lite';

  // Risk Levels
  static const String riskSafe = 'Safe';
  static const String riskSuspicious = 'Suspicious';
  static const String riskDangerous = 'Dangerous';

  // Colors
  static const Color safeColor = Colors.green;
  static const Color suspiciousColor = Colors.orange;
  static const Color dangerousColor = Colors.red;
  static const Color neutralColor = Colors.grey;

  // Messages
  static const String scanTooltip = 'Scan QR Code';
  static const String uploadTooltip = 'Upload from Gallery';
  static const String safeMessage = 'No obvious threats detected.';
  static const String suspiciousMessage = 'Proceed with caution.';
  static const String dangerousMessage = 'High risk detected! Do not open.';
}
