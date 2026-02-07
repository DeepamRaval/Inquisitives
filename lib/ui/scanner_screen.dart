import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'result_screen.dart';
import '../core/constants.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isScanned = false;

  void _handleBarcode(BarcodeCapture capture) {
    if (_isScanned) return;
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isScanned = true;
        });
        controller.stop(); // Stop scanning to prevent multiple triggers
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(rawValue: barcode.rawValue!),
          ),
        );
        break;
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.white);
                  case TorchState.on:
                    return Icon(
                      Icons.flash_on,
                      color: AppConstants.secondaryColor,
                    );
                  case TorchState.auto:
                    return const Icon(Icons.flash_auto, color: Colors.white);
                  case TorchState.unavailable:
                    return const Icon(Icons.no_flash, color: Colors.grey);
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, child) {
                return const Icon(Icons.cameraswitch, color: Colors.white);
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _handleBarcode),
          // Custom Overlay
          CustomPaint(painter: ScannerOverlayPainter(), child: Container()),
          // Scan Animation
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
              ),
              child: Stack(
                children: [
                  // Glowing corners provided by Painter, this is just for alignment
                  // Scanning Line
                  Center(
                    child:
                        Container(
                              width: 240,
                              height: 2,
                              decoration: BoxDecoration(
                                color: AppConstants.secondaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppConstants.secondaryColor,
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            )
                            .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true),
                            )
                            .slideY(
                              begin: -60,
                              end: 60,
                              duration: 2.seconds,
                              curve: Curves.linear,
                            ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Text
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              'Point camera at a QR code',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = 250;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final Rect scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Dark Background Overlay
    final paintBg = Paint()..color = Colors.black.withOpacity(0.6);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(
          RRect.fromRectAndRadius(scanRect, const Radius.circular(20)),
        ),
      ),
      paintBg,
    );

    // Glowing Corners
    final paintCorners = Paint()
      ..color = AppConstants.secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final double cornerSize = 30;
    final double radius = 20;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerSize)
        ..lineTo(left, top + radius)
        ..arcToPoint(
          Offset(left + radius, top),
          radius: Radius.circular(radius),
        )
        ..lineTo(left + cornerSize, top),
      paintCorners,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - cornerSize, top)
        ..lineTo(left + scanAreaSize - radius, top)
        ..arcToPoint(
          Offset(left + scanAreaSize, top + radius),
          radius: Radius.circular(radius),
        )
        ..lineTo(left + scanAreaSize, top + cornerSize),
      paintCorners,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + scanAreaSize - cornerSize)
        ..lineTo(left, top + scanAreaSize - radius)
        ..arcToPoint(
          Offset(left + radius, top + scanAreaSize),
          radius: Radius.circular(radius),
          clockwise: false,
        )
        ..lineTo(left + cornerSize, top + scanAreaSize),
      paintCorners,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - cornerSize, top + scanAreaSize)
        ..lineTo(left + scanAreaSize - radius, top + scanAreaSize)
        ..arcToPoint(
          Offset(left + scanAreaSize, top + scanAreaSize - radius),
          radius: Radius.circular(radius),
          clockwise: false,
        )
        ..lineTo(left + scanAreaSize, top + scanAreaSize - cornerSize),
      paintCorners,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
