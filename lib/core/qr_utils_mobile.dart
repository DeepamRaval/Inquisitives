import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Future<String?> scanQrFromImage(XFile file) async {
  final controller = MobileScannerController();
  try {
    final BarcodeCapture? barcodes = await controller.analyzeImage(file.path);
    if (barcodes != null && barcodes.barcodes.isNotEmpty) {
      return barcodes.barcodes.first.rawValue;
    }
  } catch (e) {
    // rethrow or return null
    print('MobileScanner error: $e');
  }
  return null;
}
