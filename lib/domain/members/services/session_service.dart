// lib/domain/members/services/session_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/session_user.dart';

// Secure Storage 키 정의
const String tokenKey = 'accessToken'; // <-- Made public
const String _userMemberIdKey = 'user_member_id';
const String _userLoginIdKey = 'user_login_id';
const String _userEmailKey = 'user_email';
const String _userNameKey = 'user_name';
const String _userRoleKey = 'user_role';
const String _userProfileImageUrlKey = 'user_profile_image_url';

class SessionService {
  final FlutterSecureStorage _secureStorage;

  // Make tokenKey accessible as a static member if preferred for namespacing,
  // or allow direct import of the top-level tokenKey constant.
  // For simplicity, using the direct import of top-level constant for now.
  // static const String tokenKey = _tokenKey; // Alternative if _tokenKey was kept private

  SessionService(this._secureStorage);

  Future<void> storeSession(SessionUser sessionUser, String token) async {
    await _secureStorage.write(
        key: tokenKey, value: token); // Use public tokenKey
    await _secureStorage.write(
        key: _userMemberIdKey, value: sessionUser.memberId.toString());
    await _secureStorage.write(key: _userRoleKey, value: sessionUser.role);
    // ... rest of the method using other private keys ...
    if (sessionUser.loginId != null) {
      await _secureStorage.write(
          key: _userLoginIdKey, value: sessionUser.loginId!);
    } else {
      await _secureStorage.delete(key: _userLoginIdKey);
    }
    if (sessionUser.email != null) {
      await _secureStorage.write(key: _userEmailKey, value: sessionUser.email!);
    } else {
      await _secureStorage.delete(key: _userEmailKey);
    }
    if (sessionUser.name != null) {
      await _secureStorage.write(key: _userNameKey, value: sessionUser.name!);
    } else {
      await _secureStorage.delete(key: _userNameKey);
    }
    if (sessionUser.profileImageUrl != null) {
      await _secureStorage.write(
          key: _userProfileImageUrlKey, value: sessionUser.profileImageUrl!);
    } else {
      await _secureStorage.delete(key: _userProfileImageUrlKey);
    }
    print("[SessionService] Session data stored.");
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: tokenKey); // Use public tokenKey
  }

  Future<SessionUser?> getStoredUser() async {
    final storedToken =
        await getAccessToken(); // Internally uses public tokenKey
    if (storedToken == null || storedToken.isEmpty) return null;

    final memberIdStr = await _secureStorage.read(key: _userMemberIdKey);
    final role = await _secureStorage.read(key: _userRoleKey);

    if (memberIdStr != null && role != null) {
      try {
        return SessionUser(
          memberId: int.parse(memberIdStr),
          loginId: await _secureStorage.read(key: _userLoginIdKey),
          email: await _secureStorage.read(key: _userEmailKey),
          name: await _secureStorage.read(key: _userNameKey),
          role: role,
          profileImageUrl:
              await _secureStorage.read(key: _userProfileImageUrlKey),
        );
      } catch (e) {
        print("[SessionService] Error parsing stored user data: $e");
        await clearSession();
        return null;
      }
    }
    return null;
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: tokenKey); // Use public tokenKey
    await _secureStorage.delete(key: _userMemberIdKey);
    await _secureStorage.delete(key: _userLoginIdKey);
    await _secureStorage.delete(key: _userEmailKey);
    await _secureStorage.delete(key: _userNameKey);
    await _secureStorage.delete(key: _userRoleKey);
    await _secureStorage.delete(key: _userProfileImageUrlKey);
    print("[SessionService] Session data cleared.");
  }
}

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final sessionServiceProvider = Provider<SessionService>((ref) {
  final secureStorage = ref.watch(flutterSecureStorageProvider);
  return SessionService(secureStorage);
});
