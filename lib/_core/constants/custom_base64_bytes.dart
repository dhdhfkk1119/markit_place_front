import 'dart:convert';
import 'dart:typed_data';
import 'package:logger/logger.dart';

final logger = Logger();

// Base64 문자열에서 프리픽스를 제거하고 바이트 데이터를 반환하는 함수
Uint8List? base64ToBytes(String? base64String) {
  if (base64String == null || base64String.isEmpty) {
    return null;
  }

  String cleanedString = base64String;

  // 'data:image/...' 프리픽스가 있다면 제거
  if (base64String.startsWith('data:image/') && base64String.contains(',')) {
    cleanedString = base64String.split(',').last;
  }

  try {
    return base64Decode(cleanedString);
  } catch (e) {
    logger.e('Error decoding Base64 string', e);
    return null;
  }
}
