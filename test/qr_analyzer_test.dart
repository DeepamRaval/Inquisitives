import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/logic/qr_analyzer.dart';
import 'package:flutter_application_1/logic/risk_assessment.dart';

void main() {
  group('QrAnalyzer Tests', () {
    final analyzer = QrAnalyzer();

    test('Analyze Safe HTTPS URL', () async {
      final result = await analyzer.analyze('https://www.google.com');
      expect(result.riskLevel, RiskLevel.safe);
      expect(result.score, 0);
    });

    test('Analyze HTTP URL', () async {
      final result = await analyzer.analyze('http://example.com');
      expect(result.score, greaterThanOrEqualTo(40));
      expect(result.riskLevel, isNot(RiskLevel.safe)); // Should be suspicious
    });

    test('Analyze IP Address URL', () async {
      final result = await analyzer.analyze('http://192.168.1.1');
      expect(result.riskLevel, RiskLevel.dangerous);
      expect(
        result.score,
        greaterThanOrEqualTo(80),
      ); // 50 (IP) + 40 (HTTP) = 90
    });

    test('Analyze Shortened URL', () async {
      final result = await analyzer.analyze('https://bit.ly/xyz');
      expect(result.score, greaterThanOrEqualTo(30));
      expect(result.riskLevel, RiskLevel.suspicious);
    });

    test('Analyze WiFi config', () async {
      final result = await analyzer.analyze(
        'WIFI:T:WPA;S:MyNetwork;P:password;;',
      );
      expect(result.riskLevel, RiskLevel.suspicious);
    });

    test('Analyze Open WiFi config', () async {
      final result = await analyzer.analyze('WIFI:T:nopass;S:FreeWifi;;');
      expect(result.riskLevel, RiskLevel.dangerous);
    });

    test('Analyze Phishing Keyword', () async {
      final result = await analyzer.analyze('https://secure-login-verify.com');
      expect(result.score, greaterThanOrEqualTo(20));
      expect(
        result.riskLevel,
        RiskLevel.suspicious,
      ); // 20 doesn't trigger susp by itself? Logic says >= 40.
      // Wait, logic says: if (score >= 40 && safe) -> suspicious.
      // Shortener + HTTPS = 30 -> Safe?
      // Let's check logic: isUrl -> HTTPS (0) + Shortener (30) = 30.
      // Logic: if (level != Dangerous) level = Suspicious.
      // So Shortener sets level=Suspicious directly.

      // Keyword: sets level=Suspicious directly if not dangerous.
    });
  });
}
