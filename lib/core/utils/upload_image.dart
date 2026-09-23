import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:http_parser/http_parser.dart';

class PreparedUploadImage {
  const PreparedUploadImage({
    required this.bytes,
    required this.filename,
    required this.contentType,
  });

  final Uint8List bytes;
  final String filename;
  final MediaType contentType;
}

/// JPG, PNG, GIF and WEBP are sent as-is. iOS photos (HEIC and similar)
/// are decoded and re-encoded as PNG, which the posts image endpoint accepts.
Future<PreparedUploadImage> prepareImageForUpload(Uint8List bytes, String filename) async {
  final MediaType? detected = detectImageMediaType(bytes);
  if (detected != null) {
    return PreparedUploadImage(
      bytes: bytes,
      filename: _filenameWithExtension(filename, detected),
      contentType: detected,
    );
  }

  final ui.Codec codec = await ui.instantiateImageCodec(
    bytes,
    targetWidth: 1600,
    allowUpscaling: false,
  );
  final ui.FrameInfo frame = await codec.getNextFrame();
  try {
    final ByteData? encoded = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    if (encoded == null) {
      throw StateError('Could not encode image');
    }
    final MediaType png = MediaType('image', 'png');
    return PreparedUploadImage(
      bytes: encoded.buffer.asUint8List(),
      filename: _filenameWithExtension(filename, png),
      contentType: png,
    );
  } finally {
    frame.image.dispose();
    codec.dispose();
  }
}

MediaType? detectImageMediaType(Uint8List bytes) {
  if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
    return MediaType('image', 'jpeg');
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return MediaType('image', 'png');
  }
  if (bytes.length >= 6 && bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38) {
    return MediaType('image', 'gif');
  }
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return MediaType('image', 'webp');
  }
  return null;
}

String _filenameWithExtension(String filename, MediaType type) {
  final String ext = type.subtype == 'jpeg' ? 'jpg' : type.subtype;
  final String base = filename.trim().isEmpty ? 'photo' : filename.trim();
  final int dot = base.lastIndexOf('.');
  final String stem = dot > 0 ? base.substring(0, dot) : base;
  return '$stem.$ext';
}
