import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../_core/utils/my_http.dart'; // secureStorage, tokenKey 사용 (accessTokenProvider)
import 'profile_repository.dart'; // 통합된 ProfileRepository

// 프로필 관련 API 레포지토리 Provider (통합된 ProfileRepository 사용)
final ProfileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(); //baseUrl 주입 삭제, Dio를 내부적으로 사용
});
