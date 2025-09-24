import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Uint8List 사용을 위해 추가

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/members/models/session_user.dart'; // SessionUser 직접 사용 가능
import '../../../../../../domain/members/providers/member_auth_provider.dart'; // authNotifierProvider 및 memberAuthRepositoryProvider를 위해 추가
import '../../../../../../domain/profile/profile.dart';

final _logger = Logger();

class MyProfileEditPage extends ConsumerStatefulWidget {
  const MyProfileEditPage({super.key});

  @override
  ConsumerState<MyProfileEditPage> createState() => _MyProfileEditPageState();
}

class _MyProfileEditPageState extends ConsumerState<MyProfileEditPage> {
  Color profileAvatarColor = Color(0xFFF5E6E6);
  final TextEditingController _nicknameController = TextEditingController();
  File? _imageFile; // 사용자가 새로 선택한 이미지 파일
  String? _newImageBase64; // 사용자가 새로 선택한 이미지의 Base64 인코딩 값
  ImageProvider? _finalImageProvider; // 최종적으로 사용할 ImageProvider

  String? _originalName; // 기존 닉네임 (변경 감지용)
  String?
      _originalImageSourceForComparison; // 기존 이미지 소스 (URL 또는 Base64, 변경 감지용)

  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authUser = ref.read(authNotifierProvider);
      if (authUser.user != null) {
        _initializeProfileData(sessionUser: authUser.user);
      }
    });
  }

  void _initializeProfileData({SessionUser? sessionUser}) {
    String nameToSet = '';
    String? imageSourceToSet; // Nullable로 변경하고 초기화

    if (sessionUser != null) {
      nameToSet = sessionUser.name ?? '';
      final base64Image = sessionUser.profileImageBase64;
      final imageUrl = sessionUser.profileImageUrl;

      if (base64Image != null && base64Image.isNotEmpty) {
        if (base64Image.startsWith('data:image') &&
            base64Image.contains('https://')) {
          _logger.w(
              '[_MyProfileEditPageState _initializeProfileData] profileImageBase64 contains data URI and URL. Preferring profileImageUrl.');
          imageSourceToSet = imageUrl; // 잘못된 형식이므로 URL 필드를 우선
        } else if (base64Image.startsWith('http')) {
          _logger.w(
              '[_MyProfileEditPageState _initializeProfileData] profileImageBase64 contains a URL. Using it as URL.');
          imageSourceToSet = base64Image; // Base64 필드에 URL이 있는 경우
        } else {
          imageSourceToSet = base64Image; // 정상적인 Base64 또는 data:image URI로 간주
        }
      }

      // profileImageBase64 처리 후 imageSourceToSet이 여전히 null이거나 비어있고, imageUrl이 유효하다면 imageUrl 사용
      if ((imageSourceToSet == null || imageSourceToSet.isEmpty) &&
          (imageUrl != null && imageUrl.isNotEmpty)) {
        imageSourceToSet = imageUrl;
      }
    }

    if (mounted) {
      _nicknameController.text = nameToSet;
      _updateDisplayImage(imageSourceToSet);

      _originalName = nameToSet;
      _originalImageSourceForComparison = imageSourceToSet;
    }
  }

  void _updateDisplayImage(String? imageSource) {
    ImageProvider? newProvider;
    if (imageSource == null || imageSource.isEmpty) {
      newProvider = null;
    } else if (imageSource.startsWith('data:image') &&
        imageSource.contains('https://')) {
      _logger.w(
          '[_MyProfileEditPageState _updateDisplayImage] Received combined data URI and URL: $imageSource');
      try {
        final uriString =
            imageSource.substring(imageSource.indexOf('https://'));
        final uri = Uri.parse(uriString);
        if (uri.isAbsolute) {
          _logger.d(
              '[_MyProfileEditPageState _updateDisplayImage] Extracted URL: $uriString');
          newProvider = NetworkImage(uriString);
        } else {
          _logger.w(
              '[_MyProfileEditPageState _updateDisplayImage] Extracted string is not a valid absolute URI: $uriString');
          newProvider = null;
        }
      } catch (e) {
        _logger.e(
            '[_MyProfileEditPageState _updateDisplayImage] Error parsing URL from combined data URI: $e');
        newProvider = null;
      }
    } else if (imageSource.startsWith('http')) {
      newProvider = NetworkImage(imageSource);
    } else {
      String base64String = imageSource;
      if (imageSource.startsWith('data:image')) {
        base64String = imageSource.split(',').last;
      }

      if (base64String.contains('http')) {
        _logger.w(
            '[_MyProfileEditPageState _updateDisplayImage] Attempting to decode a URL-like string as Base64 (post-prefix check): $base64String');
        newProvider = null;
      } else {
        try {
          final bytes = base64Decode(base64String);
          newProvider = MemoryImage(bytes);
        } catch (e) {
          _logger.e(
              "[_MyProfileEditPageState _updateDisplayImage] Error decoding base64 image for display: $e, Source: $imageSource");
          newProvider = null;
        }
      }
    }

    if (mounted) {
      setState(() {
        _finalImageProvider = newProvider;
      });
    }
  }

  Widget _buildProfileImage() {
    ImageProvider? imageToDisplay = _finalImageProvider;
    if (_imageFile != null) {
      imageToDisplay = FileImage(_imageFile!); // 새로 선택한 로컬 파일이 최우선
    }

    if (imageToDisplay != null) {
      return CircleAvatar(
          radius: 50,
          backgroundColor: profileAvatarColor,
          backgroundImage: imageToDisplay);
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: profileAvatarColor,
        child: const Icon(Icons.person, size: 60, color: Colors.white),
      );
    }
  }

  Future<void> _onEditPressed(ProfileEditViewModel viewModel) async {
    final authState = ref.read(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated ||
        authState.user == null) {
      _logger.w(
          "[MyProfileEditPage _onEditPressed] Not authenticated, aborting save.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("세션이 만료되어 저장할 수 없습니다. 다시 로그인해주세요.")),
        );
        Navigator.pushNamedAndRemoveUntil(
            context, '/social-login', (route) => false);
      }
      return;
    }

    final nickname = _nicknameController.text.trim();
    final String? imageToSend = _newImageBase64;

    final bool isNameChanged = nickname != (_originalName ?? '');
    final bool isImageChanged = _newImageBase64 != null;

    if (!isNameChanged && !isImageChanged) {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('변경사항 없음'),
          content: const Text('기존 이름과 프로필을 그대로 이용하시겠습니까?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('취소')),
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('확인')),
          ],
        ),
      );
      if (result == true && mounted) Navigator.pop(context);
      return;
    }
    await _onSave(viewModel, nickname, imageToSend);
  }

  Future<void> _pickImage() async {
    final isLoading = ref.read(profileEditViewModelProvider).isLoading;
    if (_isPickingImage || isLoading) return;
    _isPickingImage = true;
    try {
      final pickedFile =
          await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        if (bytes.length > 5 * 1024 * 1024) {
          // 5MB Limit
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미지는 5MB 이하만 가능합니다.')),
          );
          return;
        }
        setState(() {
          _imageFile = file;
          _newImageBase64 = base64Encode(bytes);
          _finalImageProvider = FileImage(_imageFile!);
        });
      }
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _onSave(ProfileEditViewModel viewModel, String nickname,
      String? imageBase64) async {
    final finalNickname = nickname.isNotEmpty ? nickname : _originalName;

    final authRepository = ref.read(memberAuthRepositoryProvider);
    final currentToken = await authRepository.getAccessToken();
    _logger.d(
        "[MyProfileEditPage _onSave] Token from SecureStorage before API call: $currentToken");

    await viewModel.editProfile(
      name: finalNickname,
      profileImageBase64: imageBase64,
    );
    final state = ref.read(profileEditViewModelProvider);
    if (state.response != null) {
      // _initializeProfileData(sessionUser: state.response); // Update with new data from server
      String? updatedImageSource;
      if (state.response!.profileImageBase64 != null &&
          state.response!.profileImageBase64!.isNotEmpty) {
        updatedImageSource = state.response!.profileImageBase64!;
      } else if (state.response!.profileImageUrl != null &&
          state.response!.profileImageUrl!.isNotEmpty) {
        updatedImageSource = state.response!.profileImageUrl!;
      }

      if (mounted) {
        setState(() {
          // Ensure setState is called within mounted check
          _showSuccess = true;
          _nicknameController.text = state.response!.name ?? '';
          _updateDisplayImage(
              updatedImageSource); // Use the centralized update logic
          _originalName = _nicknameController.text;
          _originalImageSourceForComparison = updatedImageSource;
          _imageFile = null;
          _newImageBase64 = null;
        });
      }

      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.refreshSessionUser(state.response!);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    } else if (state.error != null) {
      _logger.e("Profile edit failed: ${state.error}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("프로필 수정 실패: ${state.error}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFF96666);
    const Color accentColor = Color(0xFFFFF7F7);
    const Color lightGrey = Color(0xFFFFFFFF);
    const Color secondaryTextColor = Color(0xFFB5A1A1);

    final authState = ref.watch(authNotifierProvider);
    final currentUser = authState.user;

    if (currentUser == null) {
      _logger.w(
          '[MyProfileEditPage] CurrentUser is null, popping or redirecting.');
      Future.microtask(() {
        if (mounted) {
          // Navigator.pushNamedAndRemoveUntil(context, '/social-login', (route) => false);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Check if initialization is needed or if user data has changed externally
    // This is a simplified check; a more robust check might involve comparing more fields or versions.
    if (_originalName == null ||
        _originalName != currentUser.name ||
        _originalImageSourceForComparison !=
            (currentUser.profileImageBase64 ?? currentUser.profileImageUrl)) {
      _initializeProfileData(sessionUser: currentUser);
    }

    final profileEditState = ref.watch(profileEditViewModelProvider);
    final viewModel = ref.read(profileEditViewModelProvider.notifier);
    final isLoading = profileEditState.isLoading;

    if (profileEditState.error?.contains('토큰이 만료되었습니다') ?? false) {
      _logger.w(
          '[MyProfileEditPage build] 토큰 만료 감지 (profileEditState.error) - 로그인 화면으로 이동 시도');
      Future.microtask(() {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      });
      return const SizedBox.shrink();
    }

    if (isLoading &&
        _finalImageProvider == null &&
        _nicknameController.text.isEmpty) {
      return const Scaffold(
        body: Center(
            child: Text('프로필 정보 불러오는 중...', style: TextStyle(fontSize: 18))),
      );
    }

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: lightGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: isLoading ? null : () => Navigator.pop(context),
        ),
        title: CustomWidget.buildTitle("프로필 수정", size: 18, color: Colors.black),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => _onEditPressed(viewModel),
            child: CustomWidget.buildTitle(isLoading ? "저장중..." : "완료",
                size: 16, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
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
                            border: Border.all(color: Colors.grey.shade300)),
                        child: Icon(Icons.camera_alt,
                            color: secondaryTextColor, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.buildTitle("닉네임",
                      size: 16,
                      weight: FontWeight.w400,
                      color: secondaryTextColor),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nicknameController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: "닉네임을 입력하세요",
                      hintStyle: TextStyle(
                          color: secondaryTextColor,
                          fontFamily: Assets.Fonts.cookieRun),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: accentColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: primaryColor, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              if (profileEditState.error != null && !_showSuccess)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(profileEditState.error!,
                      style: const TextStyle(color: Colors.red)),
                ),
              if (_showSuccess)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text("프로필이 성공적으로 수정되었습니다!",
                      style: const TextStyle(color: Colors.green)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
