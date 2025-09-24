import 'dart:io';
import 'dart:typed_data'; // Uint8List 사용을 위해 추가

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart'; // <<< SVG 사용을 위해 추가
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_base64_bytes.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../_core/utils/error_utils.dart'; // extractErrorMessage
import '../../../../../../domain/members/models/session_user.dart';
import '../../../../../../domain/members/providers/member_auth_provider.dart';
import '../../../../../../domain/profile/profile.dart';
import '../../../../../../_core/constants/size.dart';

final _logger = Logger();

class MyProfileEditPage extends ConsumerStatefulWidget {
  const MyProfileEditPage({super.key});

  @override
  ConsumerState<MyProfileEditPage> createState() => _MyProfileEditPageState();
}

class _MyProfileEditPageState extends ConsumerState<MyProfileEditPage> {
  Color profileAvatarColor = const Color(0xFFF5E6E6);
  final TextEditingController _nicknameController = TextEditingController();

  File? _selectedImageFile;
  ImageProvider?
      _finalImageProvider; // UI 표시용 (FileImage, NetworkImage, MemoryImage 등)
  Widget? _profileAvatarWidget; // 최종적으로 CircleAvatar에 들어갈 위젯

  String? _originalName;
  String? _originalImageSourceForComparison; // 초기 이미지 식별자 (URL 또는 Base64 일부)

  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;
  bool _isSavingProfile = false;

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
    if (sessionUser == null) return;

    final nameToSet = sessionUser.name ?? '';
    final provider = sessionUser.provider?.toUpperCase();
    String?
        imageSourceToSet; // Network URL or Base64 string for initial display

    if (provider == "GOOGLE" || provider == "NAVER") {
      imageSourceToSet = sessionUser.profileImageUrl;
    } else {
      // 일반 로그인 사용자: Base64 우선, 다음 URL
      final base64Image = sessionUser.profileImageBase64;
      final imageUrl = sessionUser.profileImageUrl;

      if (base64Image != null && base64Image.isNotEmpty) {
        if (base64Image.startsWith('data:image') &&
            base64Image.contains('https://')) {
          imageSourceToSet = imageUrl; // 잘못된 형식
        } else if (base64Image.startsWith('http')) {
          imageSourceToSet = base64Image; // URL이 Base64 필드에 있는 경우
        } else {
          imageSourceToSet = base64Image; // 순수 Base64
        }
      }
      if ((imageSourceToSet == null || imageSourceToSet.isEmpty) &&
          (imageUrl != null && imageUrl.isNotEmpty)) {
        imageSourceToSet = imageUrl;
      }
    }

    if (mounted) {
      _nicknameController.text = nameToSet;
      _updateDisplayImageFromSource(imageSourceToSet, provider);
      _originalName = nameToSet;
      _originalImageSourceForComparison = imageSourceToSet; // 비교용 원본 소스 저장
    }
  }

  void _updateDisplayImageFromSource(String? imageSource, String? provider) {
    Widget newAvatarWidget;
    ImageProvider? newImageProvider; // _finalImageProvider 업데이트용

    if (provider == "GOOGLE" || provider == "NAVER") {
      if (imageSource != null &&
          imageSource.isNotEmpty &&
          imageSource.startsWith('http')) {
        newImageProvider = NetworkImage(imageSource);
        newAvatarWidget = ClipOval(
          child: Image.network(
            imageSource,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return SvgPicture.asset(
                provider == "GOOGLE" ? Assets.Svgs.google : Assets.Svgs.naver,
                fit: BoxFit.contain,
                width: 60,
                height: 60,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      } else {
        newAvatarWidget = CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: SvgPicture.asset(
            provider == "GOOGLE" ? Assets.Svgs.google : Assets.Svgs.naver,
            fit: BoxFit.contain,
            width: 70,
            height: 70,
          ),
        );
      }
    } else {
      // 일반 사용자
      if (imageSource != null && imageSource.isNotEmpty) {
        if (imageSource.startsWith('http')) {
          newImageProvider = NetworkImage(imageSource);
        } else if (imageSource.startsWith('data:image') &&
            imageSource.contains('https://')) {
          // 잘못된 형식, 기본 아이콘으로
        } else {
          final Uint8List? imageBytes =
              base64ToBytes(imageSource); // Prefix 제거 포함
          if (imageBytes != null) {
            newImageProvider = MemoryImage(imageBytes);
          }
        }
      }
      newAvatarWidget = CircleAvatar(
        radius: 50,
        backgroundColor: profileAvatarColor,
        backgroundImage: newImageProvider,
        child: newImageProvider == null
            ? const Icon(Icons.person, size: 60, color: Colors.white)
            : null,
      );
    }

    if (mounted) {
      setState(() {
        _profileAvatarWidget = newAvatarWidget;
        _finalImageProvider =
            newImageProvider; // _pickImage 이후 FileImage와 비교하기 위해
        _selectedImageFile = null; // 소스 변경 시 선택된 파일 초기화
      });
    }
  }

  Widget _buildProfileImage() {
    // _selectedImageFile이 있으면 FileImage를 사용한 아바타를, 아니면 _profileAvatarWidget을 표시
    if (_selectedImageFile != null) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: profileAvatarColor,
        backgroundImage: FileImage(_selectedImageFile!),
      );
    }
    return _profileAvatarWidget ??
        CircleAvatar(
          // 초기 null 상태 방지
          radius: 50,
          backgroundColor: profileAvatarColor,
          child: const Icon(Icons.person, size: 60, color: Colors.white),
        );
  }

  Future<void> _pickImage(bool isSocialUser) async {
    if (isSocialUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("소셜 로그인 프로필 이미지는 해당 플랫폼에서 변경해주세요.")),
      );
      return;
    }
    if (_isPickingImage ||
        _isSavingProfile ||
        (ref.read(profileEditViewModelProvider).isLoading)) return;
    _isPickingImage = true;
    try {
      final XFile? pickedXFile =
          await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
      if (pickedXFile != null) {
        final file = File(pickedXFile.path);
        final bytes = await file.readAsBytes();
        if (bytes.length > 5 * 1024 * 1024) {
          // 5MB 제한
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이미지는 5MB 이하만 가능합니다.')),
            );
          }
          return;
        }
        setState(() {
          _selectedImageFile = file;
          // _finalImageProvider = FileImage(_selectedImageFile!); // _buildProfileImage에서 처리
        });
      }
    } catch (e) {
      _logger.e("[_MyProfileEditPageState _pickImage] Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("이미지를 선택하는 중 오류가 발생했습니다: ${extractErrorMessage(e)}")),
        );
      }
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _onEditPressed(
      ProfileEditViewModel viewModel, bool isSocialUser) async {
    if (isSocialUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("소셜 로그인 프로필은 여기서 수정할 수 없습니다.")),
      );
      return;
    }
    if (_isSavingProfile) return;

    final authState = ref.read(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated ||
        authState.user == null) {
      _logger.w("[MyProfileEditPage _onEditPressed] Not authenticated");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("세션 만료. 다시 로그인해주세요.")),
        );
        Navigator.pushNamedAndRemoveUntil(
            context, '/social-login', (route) => false);
      }
      return;
    }

    final nickname = _nicknameController.text.trim();
    final bool isNameChanged = nickname != (_originalName ?? '');
    final bool isImageChanged = _selectedImageFile != null;

    if (!isNameChanged && !isImageChanged) {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('변경사항 없음'),
          content: const Text('기존 프로필을 그대로 이용하시겠습니까?'),
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

    String? base64ImageForServer;
    if (_selectedImageFile != null) {
      try {
        final bytes = await _selectedImageFile!.readAsBytes();
        base64ImageForServer = bytesToBase64(bytes); // Prefix 없는 순수 Base64
      } catch (e) {
        _logger.e("Error reading/encoding file for Base64: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("이미지 처리 중 오류: ${extractErrorMessage(e)}")),
          );
        }
        return;
      }
    }
    await _onSave(viewModel, nickname, base64ImageForServer);
  }

  Future<void> _onSave(ProfileEditViewModel viewModel, String nickname,
      String? imageBase64ForServer) async {
    if (_isSavingProfile) return;

    final finalNickname = nickname.isNotEmpty ? nickname : _originalName;

    setState(() {
      _isSavingProfile = true;
    });

    try {
      await viewModel.editProfile(
        name: finalNickname,
        profileImageBase64: imageBase64ForServer, // 서버는 Base64만 받음
      );

      final profileEditState = ref.read(profileEditViewModelProvider);
      if (mounted && profileEditState.response != null) {
        final updatedUser = profileEditState.response!;
        // AuthNotifier 상태 업데이트
        final authNotifier = ref.read(authNotifierProvider.notifier);
        await authNotifier.refreshSessionUser(updatedUser);

        // 현재 페이지 상태 업데이트 (서버에서 받은 정보 기준)
        _initializeProfileData(sessionUser: updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("프로필이 성공적으로 수정되었습니다!")),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              // 저장 완료 후 _isSavingProfile이 false가 된 후에 pop 가능하도록
              setState(() {
                _isSavingProfile = false;
              }); // 완료 시 _isSavingProfile 해제
              if (Navigator.canPop(context)) Navigator.pop(context);
            }
          });
        }
      } else if (mounted && profileEditState.error != null) {
        _logger.e("Profile edit failed: ${profileEditState.error}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("프로필 수정 실패: ${profileEditState.error}")),
        );
        setState(() {
          _isSavingProfile = false;
        });
      } else {
        setState(() {
          _isSavingProfile = false;
        });
      }
    } catch (e) {
      _logger.e("Error in _onSave during editProfile call: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "프로필 저장 중 예기치 않은 오류가 발생했습니다: ${extractErrorMessage(e)}")),
        );
      }
      setState(() {
        _isSavingProfile = false;
      });
    }
    // finally 블록을 제거하고 각 분기에서 _isSavingProfile을 false로 설정
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
      _logger.w('[MyProfileEditPage] CurrentUser is null, redirecting.');
      Future.microtask(() {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/social-login', (route) => false);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String? provider = currentUser.provider?.toUpperCase();
    final bool isSocialUser = provider == "GOOGLE" || provider == "NAVER";

    // 데이터 동기화 로직 (외부에서 변경되었을 수 있으므로)
    // _originalName은 initState에서 한번 설정되므로, currentUser.name과 비교하여 변경 감지
    String? currentImageIdentifier;
    if (isSocialUser) {
      currentImageIdentifier = currentUser.profileImageUrl;
    } else {
      currentImageIdentifier =
          currentUser.profileImageBase64 ?? currentUser.profileImageUrl;
    }

    if (_originalName != currentUser.name ||
        _originalImageSourceForComparison != currentImageIdentifier) {
      _logger.d(
          "[MyProfileEditPage build] User data changed externally or initial load. Re-initializing.");
      _initializeProfileData(sessionUser: currentUser);
    }

    final profileEditVMisLoading =
        ref.watch(profileEditViewModelProvider.select((s) => s.isLoading));
    final viewModel = ref.read(profileEditViewModelProvider.notifier);
    final bool currentOperationInProgress =
        _isSavingProfile || profileEditVMisLoading;

    // ... (기존 로딩 및 오류 처리 로직 일부 유지 가능)

    return WillPopScope(
      onWillPop: () async {
        if (_isSavingProfile) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("프로필 저장 중에는 나갈 수 없습니다.")),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: AppBar(
          backgroundColor: lightGrey,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: _isSavingProfile ? null : () => Navigator.pop(context),
          ),
          title:
              CustomWidget.buildTitle("프로필 수정", size: 18, color: Colors.black),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: currentOperationInProgress || isSocialUser
                  ? null // 소셜 유저거나 작업 중이면 비활성화
                  : () => _onEditPressed(viewModel, isSocialUser),
              child: CustomWidget.buildTitle(
                  currentOperationInProgress ? "처리중..." : "완료",
                  size: 16,
                  color: currentOperationInProgress || isSocialUser
                      ? Colors.grey
                      : Colors.black),
            ),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: medium),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Stack(
                      children: [
                        _buildProfileImage(), // 이 함수가 _profileAvatarWidget 또는 FileImage 사용
                        if (!isSocialUser) // 소셜 유저가 아닐 때만 카메라 아이콘 표시
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: currentOperationInProgress
                                  ? null
                                  : () => _pickImage(isSocialUser),
                              child: Container(
                                padding: const EdgeInsets.all(xSmall),
                                decoration: BoxDecoration(
                                    color: accentColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.grey.shade300)),
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
                        const SizedBox(height: small),
                        TextField(
                          controller: _nicknameController,
                          enabled: !currentOperationInProgress &&
                              !isSocialUser, // 소셜 유저면 비활성화
                          decoration: InputDecoration(
                            hintText:
                                isSocialUser ? "소셜 프로필 닉네임입니다" : "닉네임을 입력하세요",
                            hintStyle: TextStyle(
                                color: secondaryTextColor,
                                fontFamily: Assets.Fonts.cookieRun),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(small + xxSmall),
                                borderSide: BorderSide(color: accentColor)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(small + xxSmall),
                                borderSide:
                                    BorderSide(color: primaryColor, width: 2)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: medium, vertical: small + xSmall),
                            fillColor: isSocialUser
                                ? Colors.grey[200]
                                : null, // 비활성 시 배경색
                            filled: isSocialUser, // 비활성 시 배경색 채움
                          ),
                        ),
                      ],
                    ),
                    // ... (오류 메시지 표시 등)
                    if (ref.watch(profileEditViewModelProvider).error != null &&
                        !(_isSavingProfile || profileEditVMisLoading) &&
                        mounted)
                      Padding(
                        padding: const EdgeInsets.only(top: medium),
                        child: Text(
                            ref.watch(profileEditViewModelProvider).error!,
                            style: TextStyle(
                                color: Colors.red,
                                fontFamily: Assets.Fonts.cookieRun)),
                      ),
                  ],
                ),
              ),
            ),
            if (_isSavingProfile)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: medium),
                      Text("프로필 저장 중...",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: Assets.Fonts.cookieRun)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
