import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'scanner_screen.dart';
import 'result_screen.dart';
import '../core/qr_utils.dart'; // Conditional import
import '../core/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        final String? code = await scanQrFromImage(image);

        if (code != null && code.isNotEmpty) {
          if (context.mounted) {
            _navigateToResult(context, code);
          }
        } else {
          if (context.mounted) {
            _showSnackBar(context, 'No QR code found in image.', isError: true);
          }
        }
      } catch (e) {
        if (context.mounted) {
          _showSnackBar(context, 'Error analyzing image: $e', isError: true);
        }
      }
    }
  }

  void _navigateToResult(BuildContext context, String rawValue) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultScreen(rawValue: rawValue)),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError
            ? AppConstants.errorColor
            : AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            right: -100,
            child:
                Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConstants.primaryColor.withOpacity(0.15),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.15),
                            blurRadius: 100,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .scale(duration: 3.seconds, curve: Curves.easeInOut)
                    .then()
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(0.9, 0.9),
                      duration: 3.seconds,
                    ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
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

          // Main Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Header
                Text(
                  'SafeScan',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn().slideY(begin: -0.5),
                Text(
                  'LITE',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.secondaryColor,
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.5),

                const Spacer(),

                // Central Pulse Button
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScannerScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConstants.surfaceColor,
                        border: Border.all(
                          color: AppConstants.primaryColor.withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                                Icons.qr_code_scanner,
                                size: 80,
                                color: AppConstants.primaryColor,
                              )
                              .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true),
                              )
                              .scaleXY(
                                begin: 1.0,
                                end: 1.1,
                                duration: 1.5.seconds,
                                curve: Curves.easeInOut,
                              ),
                          const SizedBox(height: 10),
                          Text(
                            'TAP TO SCAN',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 1.2,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

                const Spacer(),

                // Gallery Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: TextButton.icon(
                    onPressed: () => _pickImage(context),
                    icon: Icon(
                      Icons.image_outlined,
                      color: AppConstants.secondaryColor,
                    ),
                    label: Text(
                      'Scan from Gallery',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      backgroundColor: AppConstants.surfaceColor.withOpacity(
                        0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
