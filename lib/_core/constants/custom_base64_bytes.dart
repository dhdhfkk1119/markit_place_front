import 'dart:convert';
import 'dart:typed_data';
import 'package:logger/logger.dart';

final logger = Logger();

// Base64 문자열에서 프리픽스를 제거하고 바이트 데이터를 반환하는 함수
Uint8List? base64ToBytes(String? base64String) {
  if (base64String == null) return null;
  final trimmed = base64String.trim();
  if (trimmed.isEmpty) return null;

  // URL 또는 data URL이 아닌 경우에만 Base64 디코드 시도
  // URL 패턴(예: http://, https://, //)을 감지하면 null 반환
  final lower = trimmed.toLowerCase();
  if (lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('//') ||
      lower.contains('://')) {
    logger.d('base64ToBytes: input looks like a URL, skipping base64 decode');
    return null;
  }

  String cleanedString = trimmed;
  // data:image/... 프리픽스가 있다면 콤마 뒤의 base64 부분만 사용
  if (cleanedString.startsWith('data:image/') && cleanedString.contains(',')) {
    cleanedString = cleanedString.split(',').last;
  }

  // 공백/줄바꿈 제거
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
