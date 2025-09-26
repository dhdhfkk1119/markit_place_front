import 'dart:convert';
import 'dart:typed_data'; // Uint8List 사용을 위해 추가

import 'package:dio/dio.dart'; // Dio (praise)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart'; // <<< SVG 사용을 위해 추가
import 'package:logger/logger.dart';

import '../../../../../../_core/constants/assets.dart'; // <<< Assets 경로 사용을 위해 추가
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../_core/utils/error_utils.dart'; // <<< extractErrorMessage 사용을 위해 추가
import '../../../../../../_core/utils/my_http.dart'; // dioProvider (praise)
import '../../../../../../domain/members/models/session_user.dart'; // SessionUser 사용
import '../../../../../../domain/members/providers/member_auth_provider.dart';
import '../../../../../../domain/profile/profile_provider.dart'; // ProfileRepositoryProvider 사용을 위해 추가
import '../../../../../../domain/trade_review/trade_review.dart'; // TradeReview 모델 추가
import '../../../../../../domain/trade_review/trade_review_provider.dart'; // 리뷰 provider 추가
import '../../../../auth/social_login_page/social_login_page.dart';
import '../review_list_screen.dart';

final praiseButtonStateProvider = StateProvider<bool>((ref) => true);

final _logger = Logger();

class MyProfileBody extends ConsumerStatefulWidget {
  final SessionUser? user;
  final int userRating;

  const MyProfileBody({this.user, required this.userRating, super.key});

  @override
  ConsumerState<MyProfileBody> createState() => _MyProfileBodyState();
}

class _MyProfileBodyState extends ConsumerState<MyProfileBody> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _fetchProfileAndRefreshAuth();
      _loadRecentReviews(); // Add this line to load reviews on init
    });
  }

  // Add this new method to load recent reviews
  Future<void> _loadRecentReviews() async {
    final userId = ref.read(authNotifierProvider).user?.memberId;
    if (userId != null) {
      try {
        await ref
            .read(recentReviewsProvider.notifier)
            .loadRecentReviews(userId);
      } catch (e) {
        _logger.e("[MyProfileBody] 최근 리뷰 로드 실패: $e", e, StackTrace.current);
      }
    }
  }

  Future<void> _fetchProfileAndRefreshAuth({bool showLoading = true}) async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final profileRepository = ref.read(ProfileRepositoryProvider);

    try {
      final SessionUser? fullUserProfile =
          await profileRepository.getMyProfile();
      if (fullUserProfile != null) {
        await authNotifier.refreshSessionUser(fullUserProfile);
        _logger.d(
            "[MyProfileBody] 프로필 정보 조회 및 AuthNotifier 상태 업데이트 성공: ${fullUserProfile.name}");
      } else {
        _logger.w("[MyProfileBody] 서버로부터 프로필 정보를 가져오지 못했습니다.");
      }
    } catch (e) {
      _logger.e("[MyProfileBody] 내 프로필 정보 조회 실패: $e", e, StackTrace.current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("프로필 정보를 불러오는데 실패했습니다: ${extractErrorMessage(e)}")),
        );
      }
    }
  }

  Future<void> _refreshProfileData() async {
    await _fetchProfileAndRefreshAuth();
  }

  Future<void> _addPraise() async {
    _logger.d('매너 칭찬하기 함수 호출됨');
    final bool isEnabled = ref.read(praiseButtonStateProvider);
    if (!isEnabled) {
      _logger.w('버튼이 비활성화 상태입니다. 함수를 종료합니다');
      return;
    }
    ref.read(praiseButtonStateProvider.notifier).state = false;
    _logger.d('버튼 상태를 비활성화로 변경함');

    final dio = ref.read(dioProvider);
    final authUser = ref.read(authNotifierProvider).user;
    final requestBody = {
      "praisedMemberId": 1,
      "praiserId": authUser?.memberId ?? 2,
      "tradeId": 1,
      "isBuyer": true,
      "praiseCategory": [1, 2],
      "customContent": "정말 좋은 거래였습니다!"
    };
    bool shouldReactivateButton = true;

    try {
      final response = await dio.post(
        '${baseUrl}/praise',
        data: requestBody,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      _logger.i("서버 응답 상태 코드 : ${response.statusCode}");
      _logger.d("서버 응답 본문 : ${response.data}");

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success']) {
          await _refreshProfileData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("매너 칭찬이 완료되었습니다. 감사합니다!")),
            );
          }
          shouldReactivateButton = false;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'] ?? "칭찬에 실패했습니다.")),
            );
          }
          if (responseData['message'] == "이미 해당 거래를 칭찬하셨습니다.") {
            shouldReactivateButton = false;
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("매너 칭찬에 실패했습니다. 다시 시도해주세요.")),
          );
        }
      }
    } catch (e) {
      _logger.e('네트워크 오류 발생', e, StackTrace.current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("네트워크 오류가 발생했습니다.")),
        );
      }
    } finally {
      if (shouldReactivateButton) {
        ref.read(praiseButtonStateProvider.notifier).state = true;
        _logger.d('버튼 상태를 다시 활성화로 변경함');
      } else {
        _logger.d('버튼 상태를 비활성화로 유지');
      }
    }
  }

  static const Color primaryColor = Color(0xFFF96666);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color profileAvatarColor = Color(0xFFF5E6E6); // 기존 배경색 유지
  static const Color redHeartColor = Colors.red;
  static const Color secondaryTextColor = Colors.grey;
  static const Color dividerColor = Color(0xFFEDE0E0);
  static const Color mainTextColor = Color(0xFF333333);
  static const double horizontalPadding = 20.0;
  static const double verticalSpacing = 24.0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final SessionUser? displayUser = widget.user ?? authState.user;

    if (displayUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SocialLoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      });
      return const SizedBox.shrink();
    }

    final profileName = displayUser.name ?? '이름 없음';
    final String? provider = displayUser.provider?.toUpperCase();

    Widget profileImageWidget;

    if (provider == "GOOGLE" || provider == "NAVER") {
      if (displayUser.profileImageUrl != null &&
          displayUser.profileImageUrl!.isNotEmpty &&
          displayUser.profileImageUrl!.startsWith('http')) {
        profileImageWidget = ClipOval(
          child: Image.network(
            displayUser.profileImageUrl!,
            width: 80, // CircleAvatar radius * 2
            height: 80, // CircleAvatar radius * 2
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              _logger.w(
                  "Error loading social profile image ($provider): ${displayUser.profileImageUrl}, Error: $error");
              if (provider == "GOOGLE") {
                return SvgPicture.asset(Assets.Svgs.google,
                    fit: BoxFit.contain, width: 50, height: 50);
              } else if (provider == "NAVER") {
                return SvgPicture.asset(Assets.Svgs.naver,
                    fit: BoxFit.contain, width: 50, height: 50);
              }
              return const Icon(Icons.person,
                  size: 40, color: Colors.white70); // 기본 폴백
            },
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        );
      } else {
        _logger.d(
            "Social profile image URL is null or invalid for $provider. Displaying SVG.");
        if (provider == "GOOGLE") {
          profileImageWidget = CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: SvgPicture.asset(Assets.Svgs.google,
                  fit: BoxFit.contain, width: 50, height: 50));
        } else {
          // NAVER
          profileImageWidget = CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: SvgPicture.asset(Assets.Svgs.naver,
                  fit: BoxFit.contain, width: 50, height: 50));
        }
      }
    } else {
      // 일반 로그인 사용자 (MARKIT 또는 기타)
      ImageProvider? generalUserImageProvider;
      String? base64ImageSource = displayUser.profileImageBase64;
      String? imageUrlSource = displayUser.profileImageUrl;

      if (base64ImageSource != null && base64ImageSource.isNotEmpty) {
        if (base64ImageSource.startsWith('data:image') &&
            base64ImageSource.contains('https://')) {
          base64ImageSource = '';
        } else if (base64ImageSource.startsWith('http')) {
          generalUserImageProvider = NetworkImage(base64ImageSource);
        } else {
          String pureBase64String = base64ImageSource;
          if (base64ImageSource.startsWith('data:image')) {
            pureBase64String = base64ImageSource.split(',').last;
          }
          if (!pureBase64String.contains('http')) {
            try {
              final bytes = base64Decode(pureBase64String);
              generalUserImageProvider = MemoryImage(bytes);
            } catch (e) {
              _logger.e(
                  '[MyProfileBody] Failed to decode profileImageBase64: $e',
                  e,
                  StackTrace.current);
            }
          }
        }
      }

      if (generalUserImageProvider == null &&
          imageUrlSource != null &&
          imageUrlSource.isNotEmpty &&
          imageUrlSource.startsWith('http')) {
        generalUserImageProvider = NetworkImage(imageUrlSource);
      }

      profileImageWidget = CircleAvatar(
        radius: 40,
        backgroundColor: profileAvatarColor,
        backgroundImage: generalUserImageProvider,
        child: generalUserImageProvider == null
            ? const Icon(Icons.person, size: 40, color: Colors.white70)
            : null,
      );
    }

    final int currentMannerScore = displayUser.mannerScore ?? 50;
    final int retransactionRate = displayUser.retransactionRate ?? 0;
    bool isSocialUser = provider == "GOOGLE" || provider == "NAVER";

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: CustomWidget.buildTitle("프로필", size: 18),
        centerTitle: true,
        actions: const [],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    profileAvatarColor, // Fallback background
                              ),
                              child: profileImageWidget,
                            ),
                            if (!isSocialUser) // 소셜 유저가 아닐 때만 수정 아이콘 표시
                              GestureDetector(
                                onTap: () {
                                  // TODO: 프로필 수정 페이지로 이동 또는 기능 구현
                                  _logger.i("Edit profile icon tapped");
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => MyProfileEditPage()));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: secondaryTextColor),
                                  ),
                                  child: const Icon(Icons.edit_outlined,
                                      color: secondaryTextColor, size: 16),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CustomWidget.buildTitle(profileName,
                                      size: 20, weight: FontWeight.w700),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // "매너 칭찬하기" 버튼은 위젯의 user (다른 사람 프로필)에게만 해당될 수 있음.
                              // 현재 로직은 widget.user 가 null이면 authState.user (자기 자신)을 사용하므로,
                              // 자기 자신에게 칭찬하기 버튼이 보일 수 있음. 이 부분은 기획에 따라 조정 필요.
                              if (widget.user != null &&
                                  widget.user?.memberId !=
                                      authState
                                          .user?.memberId) // 다른 사람 프로필 볼 때만
                                OutlinedButton(
                                  onPressed: (widget.userRating >= 1 &&
                                          ref.watch(praiseButtonStateProvider))
                                      ? _addPraise
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: (widget.userRating >= 1 &&
                                                ref.watch(
                                                    praiseButtonStateProvider))
                                            ? primaryColor
                                            : Colors.grey),
                                    backgroundColor: (widget.userRating >= 1 &&
                                            ref.watch(
                                                praiseButtonStateProvider))
                                        ? primaryColor
                                        : Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 10),
                                    minimumSize: Size.zero,
                                  ),
                                  child: CustomWidget.buildTitle("매너 칭찬하기",
                                      size: 18,
                                      color: (widget.userRating >= 1 &&
                                              ref.watch(
                                                  praiseButtonStateProvider))
                                          ? backgroundColor
                                          : Colors.white60,
                                      weight: FontWeight.normal),
                                ),
                            ],
                          ),
                        )
                      ]),
                ),
                const SizedBox(height: verticalSpacing),
                _buildRateSection(currentMannerScore, retransactionRate),
                const SizedBox(height: verticalSpacing),
                _buildListTile(
                    title: "판매 물품", subTitle: "판매 중인 물품이 없습니다", onTap: () {}),
                const SizedBox(height: verticalSpacing),
                _buildListTile(title: "받은 매너 평가", onTap: () {}),
                const SizedBox(height: 10),
                _buildMannerSection(),
                const SizedBox(height: verticalSpacing),
                _buildListTile(
                  title: "받은 거래 후기",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReviewListScreen()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildRecentReviewsSection(), // 제목도 '받은 거래 후기'로 통일
                const SizedBox(height: verticalSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRateSection(int mannerScore, int retransactionRate) {
    return Row(
      children: [
        Expanded(
          child: _buildRateBox(
            icon: Icons.favorite,
            rate: "${mannerScore}%", // API 응답이 백분율이 아니라면 캘리브레이션 필요
            text: "평균 평점",
            subText: "9명 중 8명 만족", // 이 값은 동적으로 변경 필요
            iconColor: redHeartColor,
            textColor: primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRateBox(
            icon: Icons.wechat,
            rate: "${retransactionRate}%",
            text: "응답률",
            subText: "보통 30분 이내 응답", // 이 값은 동적으로 변경 필요
            iconColor: primaryColor,
            textColor: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMannerSection() {
    // TODO: 실제 매너 평가 데이터로 교체
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMannerRow(
            icon: Icons.favorite,
            count: 8,
            text: "친절하고 매너가 좋아요.",
            iconColor: redHeartColor),
        _buildMannerRow(
            icon: Icons.access_time_filled,
            count: 5,
            text: "시간 약속을 잘 지켜요.",
            iconColor: mainTextColor),
        _buildMannerRow(
            icon: Icons.wechat_rounded,
            count: 5,
            text: "응답이 빨라요.",
            iconColor: mainTextColor),
      ],
    );
  }

  Widget _buildRateBox({
    required IconData icon,
    required String rate,
    required String text,
    required String subText,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(128, 128, 128, 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 5),
              CustomWidget.buildTitle(text,
                  size: 14, color: textColor, weight: FontWeight.normal),
            ],
          ),
          const SizedBox(height: 8),
          CustomWidget.buildTitle(rate,
              size: 22, color: textColor, weight: FontWeight.w700),
          const SizedBox(height: 8),
          CustomWidget.buildTitle(subText,
              size: 12, color: secondaryTextColor, weight: FontWeight.normal),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subTitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: dividerColor)),
        ),
        child: Row(
          children: [
            CustomWidget.buildTitle(title, size: 16, weight: FontWeight.w700),
            const SizedBox(width: 8),
            if (subTitle != null)
              CustomWidget.buildTitle(subTitle,
                  size: 16,
                  color: secondaryTextColor,
                  weight: FontWeight.normal),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: secondaryTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildMannerRow({
    required IconData icon,
    required int count,
    required String text,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(128, 128, 128, 0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3)),
              ],
            ),
            child: Icon(icon, color: iconColor ?? primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          CustomWidget.buildTitle(count.toString(),
              size: 16, weight: FontWeight.w700),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(128, 128, 128, 0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3)),
              ],
            ),
            child: CustomWidget.buildTitle(text,
                size: 12, color: mainTextColor, weight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReviewsSection() {
    final reviewState = ref.watch(recentReviewsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Color.fromRGBO(128, 128, 128, 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 제거(위에서 이미 타이틀이 있음)
          const SizedBox(height: 4),

          // 로딩 중일 때 표시
          if (reviewState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          // 에러나 리뷰 없음 모두 동일하게 안내 문구 표시
          else if (reviewState.error != null || reviewState.reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CustomWidget.buildTitle("아직 받은 거래 후기가 없습니다.",
                    size: 14, color: secondaryTextColor),
              ),
            )
          // 리뷰가 있을 경우(최대 3개만 표시)
          else
            Column(
              children: reviewState.reviews
                  .take(3)
                  .map((review) => _buildReviewItem(review))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(TradeReview review) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Color.fromRGBO(128, 128, 128, 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 거래 상대방 정보
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: profileAvatarColor,
                child:
                    const Icon(Icons.person, size: 16, color: Colors.white70),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomWidget.buildTitle(review.reviewerLoginId,
                    size: 14, weight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 별점
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                size: 16,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 리뷰 내용
          CustomWidget.buildTitle(review.content,
              size: 14, color: mainTextColor, weight: FontWeight.normal),
          const SizedBox(height: 8),
          // 작성 날짜
          CustomWidget.buildTitle(_formatDate(review.createdAt),
              size: 12, color: secondaryTextColor, weight: FontWeight.normal),
        ],
      ),
    );
  }

  // ISO 8601 형식의 날짜 문자열을 YYYY.MM.DD 형식으로 변환
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }
}
