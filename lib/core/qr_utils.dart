export 'qr_utils_stub.dart'
    if (dart.library.io) 'qr_utils_mobile.dart'
    if (dart.library.js_interop) 'qr_utils_web.dart';
