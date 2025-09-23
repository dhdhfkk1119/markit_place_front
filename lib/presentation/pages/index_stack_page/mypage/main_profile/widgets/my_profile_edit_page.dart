import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import 'package:dio/dio.dart';
import '../../../../../../_core/utils/my_http.dart';
import '../../../../../../domain/profile/profile.dart';
import '../../../../../../domain/profile/profile_provider.dart';

final _logger = Logger();

class MyProfileEditPage extends ConsumerStatefulWidget {
  const MyProfileEditPage({super.key});

  @override
  ConsumerState<MyProfileEditPage> createState() => _MyProfileEditPageState();
}

class _MyProfileEditPageState extends ConsumerState<MyProfileEditPage> {
  Color profileAvatarColor = Color(0xFFF5E6E6);
  final TextEditingController _nicknameController = TextEditingController();
  File? _imageFile;
  String? _imageBase64;
  String? _profileImageUrl;
  String? _originalName; // 기존 닉네임
  String? _originalImage; // 기존 이미지(Base64)
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;
  bool _showSuccess = false;

  Widget _buildProfileImage() {
    if (_imageFile != null) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: profileAvatarColor,
        backgroundImage: FileImage(_imageFile!),
      );
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      // URL이면 NetworkImage로 바로 표시
      if (_profileImageUrl!.startsWith('http')) {
        return CircleAvatar(
          radius: 50,
          backgroundColor: profileAvatarColor,
          backgroundImage: NetworkImage(_profileImageUrl!),
        );
      }
      try {
        return CircleAvatar(
          radius: 50,
          backgroundColor: profileAvatarColor,
          backgroundImage: MemoryImage(base64Decode(_profileImageUrl!)),
        );
      } catch (_) {
        return CircleAvatar(
          radius: 50,
          backgroundColor: profileAvatarColor,
          child: const Icon(Icons.person, size: 60, color: Colors.white),
        );
      }
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: profileAvatarColor,
        child: const Icon(Icons.person, size: 60, color: Colors.white),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profileInfoAsync = ref.read(profileInfoFutureProvider);
    profileInfoAsync.whenData((info) {
      // delegate to async handler to avoid async callback issues
      _handleProfileInfo(info);
    });
  }

  Future<void> _handleProfileInfo(dynamic info) async {
    if (info == null) {
      _logger.w('[MyProfileEditPage] profile info is null');
      return;
    }

    try {
      final name = (info.name == null) ? '' : info.name.toString();
      if (_nicknameController.text.isEmpty) {
        _nicknameController.text = name;
      }
    } catch (e) {
      _logger.e(
          '[MyProfileEditPage] failed to set nickname from profile info', e);
    }

    try {
      String img = '';
      final rawImg = (info.profileImageBase64 == null)
          ? ''
          : info.profileImageBase64.toString();
      if (rawImg.isNotEmpty) {
        img = rawImg;
      }

      // If server provided a URL, keep the URL and render via NetworkImage.
      if (img.isNotEmpty && img.startsWith('http')) {
        _logger.d(
            '[MyProfileEditPage] profile image is a URL, will render via NetworkImage: $img');
        // keep img as-is (URL). Do NOT download here to avoid timeouts.
      }

      setState(() {
        _profileImageUrl = (img.isNotEmpty) ? img : '';
        _originalName = (info.name == null) ? '' : info.name.toString();
        _originalImage = (img.isNotEmpty) ? img : '';
      });
    } catch (e) {
      _logger.e('[MyProfileEditPage] failed to set profile image/originals', e);
    }
  }

  Future<void> _onEditPressed(ProfileEditViewModel viewModel) async {
    final nickname = _nicknameController.text.trim();
    final imageBase64 = _imageBase64 ?? _profileImageUrl ?? '';
    final isNameChanged = nickname != (_originalName ?? '');
    final isImageChanged = imageBase64 != (_originalImage ?? '');
    if (!isNameChanged && !isImageChanged) {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('변경사항 없음'),
          content: const Text('기존 이름과 프로필을 그대로 이용하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      if (result == true) {
        Navigator.pop(context); // 바디로 이동
      }
      // 취소면 아무 동작 없음(에딧에 머무름)
      return;
    }
    // 변경사항이 있으면 기존대로 수정 요청 진행
    await _onSave(viewModel);
  }

  Future<void> _pickImage() async {
    final isLoading = ref.read(profileEditViewModelProvider).isLoading;
    if (_isPickingImage || isLoading) return; // 수정 중에는 이미지 선택 불가
    _isPickingImage = true;
    try {
      final pickedFile =
          await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        if (bytes.length > 7000000) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미지는 5MB 이하만 가능합니다.')),
          );
          return;
        }
        setState(() {
          _imageFile = file;
          _imageBase64 = base64Encode(bytes);
        });
      }
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _onSave(ProfileEditViewModel viewModel) async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty && _imageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임 또는 이미지를 입력하세요.')),
      );
      return;
    }
    await viewModel.editProfile(
      name: nickname.isNotEmpty ? nickname : null,
      profileImage: _imageBase64,
    );
    final state = ref.read(profileEditViewModelProvider);
    if (state.response != null) {
      setState(() {
        _showSuccess = true;
        // 수정 성공 시 최신 데이터로 갱신
        _nicknameController.text = state.response!.name;
        // 서버에서 profileImageBase64가 반환되므로 그대로 저장
        _profileImageUrl = state.response!.profileImageBase64;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 새로운 색상 팔레트 (봄 웜톤)
    const Color primaryColor = Color(0xFFF96666);
    const Color accentColor = Color(0xFFFFF7F7);
    const Color lightGrey = Color(0xFFFFFFFF);
    const Color secondaryTextColor = Color(0xFFB5A1A1);

    final asyncProfileInfo = ref.watch(profileInfoFutureProvider);
    final state = ref.watch(profileEditViewModelProvider);
    final viewModel = ref.read(profileEditViewModelProvider.notifier);
    final isLoading = state.isLoading;

    // 토큰 만료 에러 발생 시 로그인 화면으로 이동
    if (state.error?.contains('토큰이 만료되었습니다') ?? false) {
      _logger.w('[MyProfileEditPage] 토큰 만료 감지 - 로그인 화면으로 이동');
      Future.microtask(() {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      return const SizedBox.shrink(); // 에러 메시지 노출 방지
    }

    // 프로필 정보 또는 수정 상태가 로딩 중이면 '불러오는중' 메시지 표시
    final isProfileInfoLoading = asyncProfileInfo is AsyncLoading;
    if (isProfileInfoLoading || isLoading) {
      return const Scaffold(
        body: Center(child: Text('불러오는중', style: TextStyle(fontSize: 18))),
      );
    }

    return asyncProfileInfo.when(
      loading: () => const Scaffold(
          body: Center(child: Text('불러오는중', style: TextStyle(fontSize: 18)))),
      error: (err, stack) {
        if (err.toString().contains('토큰이 만료되었습니다')) {
          _logger.w('[MyProfileEditPage] 프로필 정보 조회에서 토큰 만료 감지 - 로그인 화면으로 이동');
          Future.microtask(() {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
          return const SizedBox.shrink(); // 에러 메시지 노출 방지
        }
        return Scaffold(
          body: Center(
              child: Text('프로필 정보 로딩 실패: $err',
                  style: TextStyle(color: Colors.red))),
        );
      },
      data: (profileInfo) {
        // 닉네임과 이미지 상태를 최신 데이터로 반영
        try {
          final name = (profileInfo == null || profileInfo.name == null)
              ? ''
              : profileInfo.name.toString();
          if (_nicknameController.text.isEmpty) {
            _nicknameController.text = name;
          }
        } catch (e) {
          _logger.e('[MyProfileEditPage] error assigning profileInfo.name', e);
        }
        try {
          final imgField =
              (profileInfo == null || profileInfo.profileImageBase64 == null)
                  ? ''
                  : profileInfo.profileImageBase64.toString();
          _profileImageUrl = imgField;
        } catch (e) {
          _logger.e(
              '[MyProfileEditPage] error assigning profileInfo.profileImageBase64',
              e);
          _profileImageUrl = '';
        }

        return Scaffold(
          backgroundColor: lightGrey,
          appBar: AppBar(
            backgroundColor: lightGrey,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
            ),
            title: CustomWidget.buildTitle(
              "프로필 수정",
              size: 18,
              color: Colors.black,
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => _onEditPressed(viewModel),
                child: CustomWidget.buildTitle(
                  isLoading ? "저장중..." : "완료",
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // 프로필 이미지 수정 영역
                Stack(
                  children: [
                    _buildProfileImage(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: isLoading ? null : _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: secondaryTextColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // 닉네임 입력 필드
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.buildTitle(
                      "닉네임",
                      size: 16,
                      weight: FontWeight.w400,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nicknameController,
                      enabled: !isLoading,
                      // 수정 중에는 입력 불가
                      decoration: InputDecoration(
                        hintText: "닉네임을 입력하세요",
                        hintStyle: TextStyle(
                          color: secondaryTextColor,
                          fontFamily: Assets.Fonts.cookieRun,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: accentColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (_showSuccess)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      "프로필이 성공적으로 수정되었습니다!",
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
