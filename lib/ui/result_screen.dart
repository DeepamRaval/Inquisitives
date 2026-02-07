import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../logic/qr_analyzer.dart';
import '../logic/risk_assessment.dart';

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
      appBar: AppBar(title: const Text('Scan Result')),
      body: FutureBuilder<RiskAssessment>(
        future: _assessmentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final assessment = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Risk Card
                  Card(
                    color: assessment.color.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: assessment.color, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            _getIconForRisk(assessment.riskLevel),
                            size: 64,
                            color: assessment.color,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            assessment.riskLevel.name.toUpperCase(),
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: assessment.color,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Safe',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: assessment.score / 100,
                                      backgroundColor: Colors.grey.shade300,
                                      color: assessment.color,
                                      minHeight: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                'Dangerous',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Risk Score: ${assessment.score}/100',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Content Section
                  const Text(
                    'Scanned Content:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SelectableText(
                      assessment.content,
                      style: const TextStyle(fontFamily: 'Courier'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Analysis Section
                  const Text(
                    'Analysis:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...assessment.vectorExplanations
                      .map(
                        (e) => ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: Text(e),
                          dense: true,
                        ),
                      )
                      .toList(),

                  const SizedBox(height: 24),

                  // Advice Section
                  const Text(
                    'Recommendation:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.blue),
                          const SizedBox(width: 16),
                          Expanded(child: Text(assessment.actionableAdvice)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Actions
                  if (assessment.riskLevel != RiskLevel.dangerous)
                    ElevatedButton.icon(
                      onPressed: _launchUrl,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open Link (Proceed with Caution)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade100,
                        foregroundColor: Colors.orange.shade900,
                      ),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Scan Another Code'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  IconData _getIconForRisk(RiskLevel level) {
    switch (level) {
      case RiskLevel.safe:
        return Icons.check_circle;
      case RiskLevel.suspicious:
        return Icons.warning;
      case RiskLevel.dangerous:
        return Icons.dangerous;
      case RiskLevel.unknown:
        return Icons.help;
    }
  }
}
