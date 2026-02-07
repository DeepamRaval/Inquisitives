import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../logic/qr_analyzer.dart';
import '../logic/risk_assessment.dart';
import '../core/constants.dart';

class ResultScreen extends StatefulWidget {
  final String rawValue;

  const ResultScreen({super.key, required this.rawValue});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<RiskAssessment> _assessmentFuture;
  final QrAnalyzer _analyzer = QrAnalyzer();

  @override
  void initState() {
    super.initState();
    _assessmentFuture = _analyzer.analyze(widget.rawValue);
  }

  Future<void> _launchUrl() async {
    final Uri? uri = Uri.tryParse(widget.rawValue);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not launch URL.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Analysis Result',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient blobs
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppConstants.primaryColor.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppConstants.secondaryColor.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.secondaryColor.withOpacity(0.1),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: FutureBuilder<RiskAssessment>(
              future: _assessmentFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppConstants.secondaryColor,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: AppConstants.errorColor),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final assessment = snapshot.data!;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Glassmorphic Result Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: AppConstants.surfaceColor.withOpacity(
                                  0.6,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Score Ring
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 120,
                                        child: CircularProgressIndicator(
                                          value: assessment.score / 100,
                                          strokeWidth: 10,
                                          backgroundColor: Colors.white
                                              .withOpacity(0.1),
                                          color: assessment.color,
                                          strokeCap: StrokeCap.round,
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${assessment.score}',
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: assessment.color,
                                            ),
                                          ),
                                          Text(
                                            '/100',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withOpacity(
                                                0.6,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ).animate().scale(
                                    duration: 800.ms,
                                    curve: Curves.easeOutBack,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    assessment.riskLevel.name.toUpperCase(),
                                    style: TextStyle(
                                      color: assessment.color,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    assessment.riskLevel == RiskLevel.safe
                                        ? 'No threats detected'
                                        : 'Potential threats found',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn().slideY(begin: 0.1),

                        const SizedBox(height: 24),

                        // Scanned Content
                        Text(
                          'SCANNED CONTENT',
                          style: TextStyle(
                            color: AppConstants.secondaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.link,
                                color: Colors.white.withOpacity(0.5),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SelectableText(
                                  assessment.content,
                                  style: const TextStyle(
                                    fontFamily: 'Courier',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Analysis List
                        if (assessment.vectorExplanations.isNotEmpty) ...[
                          Text(
                            'RISK FACTORS',
                            style: TextStyle(
                              color: AppConstants.secondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...assessment.vectorExplanations.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppConstants.warningColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      e,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Recommendation
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppConstants.primaryColor.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: AppConstants.primaryColor,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  assessment.actionableAdvice,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 400.ms),

                        const SizedBox(height: 32),

                        // Actions
                        if (assessment.riskLevel != RiskLevel.dangerous)
                          ElevatedButton.icon(
                            onPressed: _launchUrl,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Open Link'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Scan Another Code'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
