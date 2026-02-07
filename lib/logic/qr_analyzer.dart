import 'risk_assessment.dart';

class QrAnalyzer {
  Future<RiskAssessment> analyze(String? content) async {
    if (content == null || content.isEmpty) {
      return RiskAssessment(
        content: 'No Content',
        riskLevel: RiskLevel.unknown,
        score: 0,
        vectorExplanations: ['Could not decode QR code.'],
        actionableAdvice: 'Try scanning again.',
      );
    }

    // Default state: Safe
    RiskLevel level = RiskLevel.safe;
    int score = 0;
    List<String> explanations = [];
    String advice = 'Content appears safe, but always be cautious.';

    // 1. Check if it's a URL
    final Uri? uri = Uri.tryParse(content);
    // rigorous check if it's a web URL
    final bool isUrl =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    if (isUrl) {
      // HTTP vs HTTPS
      if (uri.scheme == 'http') {
        level = RiskLevel.suspicious;
        score += 40;
        explanations.add(
          'Unencrypted connection (HTTP). Data can be intercepted.',
        );
        advice = 'Avoid entering sensitive info on this site.';
      } else {
        explanations.add('Encrypted connection (HTTPS).');
      }

      // IP Address Check
      // regex for IP address
      final ipRegExp = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
      if (ipRegExp.hasMatch(uri.host)) {
        level = RiskLevel.dangerous;
        score += 50;
        explanations.add(
          'Direct IP address used. This is common in phishing to bypass filters.',
        );
        advice = 'Do NOT proceed. Legitimate sites use domain names.';
      }

      // URL Shorteners (Basic List)
      final shorteners = [
        'bit.ly',
        'goo.gl',
        'tinyurl.com',
        'is.gd',
        'cli.gs',
        't.co',
        'tr.im',
      ];
      if (shorteners.any((s) => uri.host.contains(s))) {
        if (level != RiskLevel.dangerous) level = RiskLevel.suspicious;
        score += 30;
        explanations.add('URL Shortener detected. Destination is hidden.');
        advice = 'Be careful. You do not know where this link leads.';
      }

      // Phishing Keywords in URL
      final suspiciousKeywords = [
        'login',
        'verify',
        'update',
        'banking',
        'secure',
        'account',
        'confirm',
      ];
      if (suspiciousKeywords.any(
        (k) => uri.host.contains(k) || uri.path.contains(k),
      )) {
        if (level != RiskLevel.dangerous) level = RiskLevel.suspicious;
        score += 20;
        explanations.add(
          'URL contains words often used in phishing (e.g., "login", "verify").',
        );
      }
    } else {
      // Non-web payloads
      final upperContent = content.toUpperCase();
      if (upperContent.startsWith('WIFI:')) {
        level = RiskLevel.suspicious;
        score += 20;
        explanations.add(
          'Wi-Fi Configuration QR. Can automatically connect you to a rogue network.',
        );
        advice = 'Verify the network name before connecting.';
        if (upperContent.contains('T:WPA') || upperContent.contains('T:WPA2')) {
          explanations.add('Encrypted network (WPA/WPA2).');
        } else if (upperContent.contains('T:NOPASS')) {
          // FIXED: matching uppercase
          level = RiskLevel.dangerous;
          score += 40;
          explanations.add('Open network (No Password). Highly insecure.');
          advice = 'Do not connect to open networks for sensitive tasks.';
        }
      } else if (upperContent.startsWith('SMSTO:') ||
          upperContent.startsWith('SMS:')) {
        level = RiskLevel.suspicious;
        score += 20;
        explanations.add(
          'SMS QR. Can initiate a text message to premium numbers.',
        );
        advice = 'Check the recipient number before sending.';
      } else if (upperContent.startsWith('MATMSG:') ||
          upperContent.startsWith('MAILTO:')) {
        level = RiskLevel.suspicious;
        score += 10;
        explanations.add('Email QR. Can prepopulate an email.');
        advice = 'Verify the recipient and content.';
      } else if (upperContent.startsWith('TEL:')) {
        level = RiskLevel.suspicious;
        score += 10;
        explanations.add('Phone Call QR. Can initiate a call.');
        advice = 'Verify the number before calling.';
      } else {
        explanations.add(
          'Plain text or unknown format. Risk is generally low unless it asks for actions.',
        );
      }
    }

    if (score > 100) score = 100;
    if (score >= 80)
      level = RiskLevel.dangerous;
    else if (score >= 40 && level == RiskLevel.safe)
      level = RiskLevel.suspicious;

    if (level == RiskLevel.safe && score > 0) {
      advice = 'Some minor issues found, but generally safe.';
    }

    return RiskAssessment(
      content: content,
      riskLevel: level,
      score: score,
      vectorExplanations: explanations,
      actionableAdvice: advice,
    );
  }
}
