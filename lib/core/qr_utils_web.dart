import 'dart:js_interop';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:web/web.dart' as web;

@JS('ZXing.BrowserMultiFormatReader')
extension type BrowserMultiFormatReader._(JSObject _) implements JSObject {
  external BrowserMultiFormatReader();
  external JSPromise<Result> decodeFromImageElement(web.HTMLImageElement image);
}

@JS()
extension type Result._(JSObject _) implements JSObject {
  external String get text;
}

Future<String?> scanQrFromImage(XFile file) async {
  try {
    final reader = BrowserMultiFormatReader();

    final img = web.document.createElement('img') as web.HTMLImageElement;
    img.src = file.path;

    await _loadImage(img);

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
