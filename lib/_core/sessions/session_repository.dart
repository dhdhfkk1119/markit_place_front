// lib/_core/sessions/repositories/session_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // FlutterSecureStorage 추가
import 'package:flutter_riverpod/flutter_riverpod.dart'; // flutterSecureStorageProvider를 위해

import '../../../_core/dtos/api_response_dto.dart';
import '../../../_core/dtos/error_dto.dart';
import '../../../_core/utils/error_utils.dart';
import '../../../_core/utils/my_http.dart'; // 전역 dio 인스턴스 사용
import '../../domain/members/dtos/login_response.dto.dart';
import 'session_user.dart'; // SessionUser로 변환하기 위해 필요

// Secure Storage 키 정의 (기존 SessionService에서 가져옴)
const String tokenKey = 'accessToken';
const String _userMemberIdKey = 'user_member_id';
const String _userLoginIdKey = 'user_login_id';
const String _userEmailKey = 'user_email';
const String _userNameKey = 'user_name';
const String _userRoleKey = 'user_role';
const String _userProfileImageUrlKey = 'user_profile_image_url';
const String _userMannerScoreKey = 'user_manner_score';
const String _userRetransactionRateKey = 'user_retransaction_rate';
const String _userUserCodeKey = 'user_user_code';

// FlutterSecureStorage를 위한 Provider
// 이 Provider는 SessionRepository를 생성하는 sessionRepositoryProvider (session_provider.dart 내)에서 사용됩니다.
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

class SessionRepository {
  final Dio _dio = dio;
  final FlutterSecureStorage _secureStorage;

  // 생성자를 통해 FlutterSecureStorage 인스턴스를 주입받음
  SessionRepository(this._secureStorage);

  /// API: 계정 기반 로그인 처리
  Future<Map<String, dynamic>> login(String loginId, String password) async {
    try {
      final dioResponse = await _dio.post(
        '/members/login',
        data: {'loginId': loginId, 'password': password},
      );
      final String? tokenHeader = dioResponse.headers.value('Authorization');
      final apiResponse = ApiResponseDto<LoginResponseDataDto>.fromJson(
        dioResponse.data as Map<String, dynamic>,
        fromJsonT: LoginResponseDataDto.fromJson,
      );
      if (tokenHeader != null &&
          tokenHeader.isNotEmpty &&
          apiResponse.success &&
          apiResponse.response != null) {
        final sessionUser = apiResponse.response!.toSessionUser();
        return {
          'sessionUser': sessionUser,
          'token': tokenHeader.replaceFirst('Bearer ', ''),
        };
      } else if (!apiResponse.success && apiResponse.error != null) {
        throw Exception(apiResponse.error!.message ?? '로그인 처리 중 알 수 없는 서버 오류');
      } else if (tokenHeader == null || tokenHeader.isEmpty) {
        throw Exception('로그인 응답에 토큰이 없습니다.');
      } else {
        throw Exception('알 수 없는 이유로 로그인에 실패했습니다.');
      }
    } on DioException catch (e) {
      final errorMessage =
          _handleDioError(e, '[SessionRepository Login Error - DioException]');
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = extractErrorMessage(e);
      print('[SessionRepository Login Error - General] \$errorMessage (\$e)');
      throw Exception(errorMessage);
    }
  }

  // --- SecureStorage 관련 메소드 ---

  /// 세션 정보(사용자 정보 및 토큰)를 SecureStorage에 저장
  Future<void> storeSessionData(SessionUser sessionUser, String token) async {
    await _secureStorage.write(key: tokenKey, value: token);
    await _secureStorage.write(
        key: _userMemberIdKey, value: sessionUser.memberId.toString());
    await _secureStorage.write(key: _userRoleKey, value: sessionUser.role);

    await _writeDataIfNotNull(_userLoginIdKey, sessionUser.loginId);
    await _writeDataIfNotNull(_userEmailKey, sessionUser.email);
    await _writeDataIfNotNull(_userNameKey, sessionUser.name);
    await _writeDataIfNotNull(
        _userProfileImageUrlKey, sessionUser.profileImageUrl);
    await _writeDataIfNotNull(
        _userMannerScoreKey, sessionUser.mannerScore?.toString());
    await _writeDataIfNotNull(
        _userRetransactionRateKey, sessionUser.retransactionRate?.toString());
    await _writeDataIfNotNull(_userUserCodeKey, sessionUser.userCode);

    print("[SessionRepository] Session data stored in SecureStorage.");
  }

  /// SecureStorage에서 Access Token 읽기
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: tokenKey);
  }

  /// SecureStorage에서 저장된 사용자 정보 읽기
  Future<SessionUser?> getStoredUser() async {
    final storedToken = await getAccessToken();
    if (storedToken == null || storedToken.isEmpty) return null;

    final memberIdStr = await _secureStorage.read(key: _userMemberIdKey);
    final role = await _secureStorage.read(key: _userRoleKey);

    if (memberIdStr != null && role != null) {
      try {
        final mannerScoreStr =
            await _secureStorage.read(key: _userMannerScoreKey);
        final retransactionRateStr =
            await _secureStorage.read(key: _userRetransactionRateKey);
        final userCode = await _secureStorage.read(key: _userUserCodeKey);
        final loginId = await _secureStorage.read(key: _userLoginIdKey);
        final email = await _secureStorage.read(key: _userEmailKey);
        final name = await _secureStorage.read(key: _userNameKey);
        final profileImageUrl =
            await _secureStorage.read(key: _userProfileImageUrlKey);

        return SessionUser(
          memberId: int.parse(memberIdStr),
          loginId: loginId,
          email: email,
          name: name,
          role: role,
          profileImageUrl: profileImageUrl,
          mannerScore:
              mannerScoreStr != null ? int.tryParse(mannerScoreStr) : null,
          retransactionRate: retransactionRateStr != null
              ? int.tryParse(retransactionRateStr)
              : null,
          userCode: userCode,
        );
      } catch (e) {
        print("[SessionRepository] Error parsing stored user data: \$e");
        await clearSessionData(); // 오류 발생 시 세션 데이터 클리어
        return null;
      }
    }
    return null;
  }

  /// SecureStorage에서 모든 세션 관련 정보 삭제
  Future<void> clearSessionData() async {
    await _secureStorage.delete(key: tokenKey);
    await _secureStorage.delete(key: _userMemberIdKey);
    await _secureStorage.delete(key: _userLoginIdKey);
    await _secureStorage.delete(key: _userEmailKey);
    await _secureStorage.delete(key: _userNameKey);
    await _secureStorage.delete(key: _userRoleKey);
    await _secureStorage.delete(key: _userProfileImageUrlKey);
    await _secureStorage.delete(key: _userMannerScoreKey);
    await _secureStorage.delete(key: _userRetransactionRateKey);
    await _secureStorage.delete(key: _userUserCodeKey);
    print("[SessionRepository] Session data cleared from SecureStorage.");
  }

  /// 내부 헬퍼: 값이 null이 아니면 SecureStorage에 저장, null이면 삭제
  Future<void> _writeDataIfNotNull(String key, String? value) async {
    if (value != null && value.isNotEmpty) {
      // 비어있지 않은 경우에만 저장
      await _secureStorage.write(key: key, value: value);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  // --- 에러 핸들링 ---
  String _handleDioError(DioException e, String logPrefix) {
    String finalErrorMessage;
    ErrorDto? parsedErrorDto;
    if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
      final responseData = e.response!.data as Map<String, dynamic>;
      if (responseData.containsKey('error') &&
          responseData['error'] != null &&
          responseData['error'] is Map<String, dynamic>) {
        try {
          parsedErrorDto =
              ErrorDto.fromJson(responseData['error'] as Map<String, dynamic>);
        } catch (parseError) {
          print('\$logPrefix - Failed to parse ErrorDto: \$parseError');
        }
      }
    }
    if (parsedErrorDto?.message != null &&
        parsedErrorDto!.message!.isNotEmpty) {
      finalErrorMessage = parsedErrorDto.message!;
    } else {
      finalErrorMessage = extractErrorMessage(e);
    }
    print(
        '\$logPrefix Final Message: \$finalErrorMessage (Dio Status: \${e.response?.statusCode})');
    if (parsedErrorDto != null) {
      print(
          '\$logPrefix Parsed ErrorDto: Code: \${parsedErrorDto.code}, Field: \${parsedErrorDto.field}, Status: \${parsedErrorDto.status}');
    }
    return finalErrorMessage;
  }
}
