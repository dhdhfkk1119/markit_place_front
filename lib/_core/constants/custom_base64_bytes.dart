import 'dart:convert';
import 'dart:typed_data';
import 'package:logger/logger.dart';

final logger = Logger();

// Base64 문자열에서 프리픽스를 제거하고 바이트 데이터를 반환하는 함수
Uint8List? base64ToBytes(String? base64String) {
  if (base64String == null) return null;
  final trimmed = base64String.trim();
  if (trimmed.isEmpty) return null;

  final lower = trimmed.toLowerCase();
  if (lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('//') ||
      lower.contains('://')) {
    logger.d('base64ToBytes: input looks like a URL, skipping base64 decode');
    return null;
  }

  String cleanedString = trimmed;
  if (cleanedString.startsWith('data:image/') && cleanedString.contains(',')) {
    cleanedString = cleanedString.split(',').last;
  }

  cleanedString = cleanedString.replaceAll(RegExp(r'\s+'), '');

  try {
    return base64Decode(cleanedString);
  } catch (e) {
    logger.w(
        'Error decoding Base64 string (not a valid base64?): ${e.toString()}');
    logger.w(cleanedString.length > 200
        ? 'base64 length: ${cleanedString.length}'
        : 'base64 content: $cleanedString');
    return null;
  }
}

// Uint8List 바이트 데이터를 Base64 문자열로 인코딩하는 함수
String? bytesToBase64(Uint8List? bytes) {
  if (bytes == null) return null;
  return base64Encode(bytes);
}
