import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:linkedin_clone/core/utils/upload_image.dart';

void main() {
  test('detects jpeg, png, gif and webp', () {
    expect(
      detectImageMediaType(Uint8List.fromList(const [0xFF, 0xD8, 0xFF, 0x00]))?.mimeType,
      'image/jpeg',
    );
    expect(
      detectImageMediaType(Uint8List.fromList(const [0x89, 0x50, 0x4E, 0x47, 0, 0, 0, 0]))?.mimeType,
      'image/png',
    );
    expect(
      detectImageMediaType(Uint8List.fromList('GIF89a'.codeUnits))?.mimeType,
      'image/gif',
    );
    expect(
      detectImageMediaType(Uint8List.fromList(const [
        0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, // RIFF
        0x57, 0x45, 0x42, 0x50, // WEBP
      ]))?.mimeType,
      'image/webp',
    );
  });

  test('unknown bytes such as HEIC are not sent as an allowed type', () {
    expect(detectImageMediaType(Uint8List.fromList(const [0, 0, 0, 0x18, 0x66, 0x74, 0x79, 0x70])), isNull);
  });
}
