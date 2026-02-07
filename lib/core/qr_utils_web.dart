import 'dart:js_interop';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:web/web.dart' as web;

@JS('ZXing')
external JSObject? get zxing;

@JS('ZXing.BrowserMultiFormatReader')
extension type BrowserMultiFormatReader._(JSObject _) implements JSObject {
  external BrowserMultiFormatReader();
  external JSPromise<Result> decodeFromImageElement(web.HTMLImageElement image);
}

@JS()
extension type Result._(JSObject _) implements JSObject {
  external String get text;
}

BrowserMultiFormatReader? _reader;

// Initialize the reader if not already done
Future<BrowserMultiFormatReader> _getReader() async {
  if (_reader != null) return _reader!;

  // Wait for ZXing library to be available (max 5 seconds)
  for (int i = 0; i < 50; i++) {
    if (zxing != null) {
      _reader = BrowserMultiFormatReader();
      return _reader!;
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }

  throw Exception('ZXing library not loaded');
}

Future<String?> scanQrFromImage(XFile file) async {
  try {
    final reader = await _getReader();

    final img = web.document.createElement('img') as web.HTMLImageElement;
    img.src = file.path;

    await _loadImage(img);

    // Add a small delay to ensure image data is ready for decoding
    await Future.delayed(const Duration(milliseconds: 100));

    final result = await reader.decodeFromImageElement(img).toDart;
    return result.text;
  } catch (e) {
    print('ZXing decoding error: $e');
    return null;
  }
}

Future<void> _loadImage(web.HTMLImageElement img) {
  final completer = Completer<void>();

  // Using generic Event for safety
  void onLoad(web.Event e) {
    completer.complete();
  }

  void onError(web.Event e) {
    completer.completeError('Failed to load image');
  }

  img.onload = onLoad.toJS;
  img.onerror = onError.toJS;

  return completer.future;
}
