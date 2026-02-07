import 'package:flutter/material.dart';
import '../core/constants.dart';

enum RiskLevel { safe, suspicious, dangerous, unknown }

class RiskAssessment {
  final String content;
  final RiskLevel riskLevel;
  final int score; // 0-100, where 100 is most dangerous
  final List<String> vectorExplanations;
  final String actionableAdvice;

  RiskAssessment({
    required this.content,
    required this.riskLevel,
    required this.score,
    required this.vectorExplanations,
    required this.actionableAdvice,
  });

  Color get color {
    switch (riskLevel) {
      case RiskLevel.safe:
        return AppConstants.safeColor;
      case RiskLevel.suspicious:
        return AppConstants.suspiciousColor;
      case RiskLevel.dangerous:
        return AppConstants.dangerousColor;
      case RiskLevel.unknown:
      default:
        return AppConstants.neutralColor;
    }
  }
}
