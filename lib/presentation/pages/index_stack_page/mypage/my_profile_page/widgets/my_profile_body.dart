import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added for ConsumerStatefulWidget
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/members/providers/member_auth_provider.dart';
import '../../../../../../domain/members/providers/profile_provider.dart'; // For ProfileNotifier
import '../../../../../../_core/sessions/session_user.dart'; // For SessionUser type
import '../review_list_screen.dart';
// import 'package:dio/dio.dart'; // Removed local Dio

class MyProfileBody extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  final SessionUser? user; // Explicitly type widget.user if possible
  const MyProfileBody({required this.user, super.key});

  @override
  ConsumerState<MyProfileBody> createState() =>
      _MyProfileBodyState(); // Changed to ConsumerState
}

class _MyProfileBodyState extends ConsumerState<MyProfileBody> {
  // Changed to ConsumerState
  int _currentMannerScore = 50; // Default or from user
  int _retransactionRate = 0; // Default or from user
  bool _isPraiseButtonEnabled = true;

  // final Dio _dio = Dio(); // Removed local Dio instance
  // final ApiService _apiService = ApiService(); // Removed ApiService instance

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  // 매너 칭찬하기
  Future<void> _addPraise() async {
    if (!_isPraiseButtonEnabled) return;

    // TODO: This method needs to be refactored to use a repository with the global Dio instance.
    // The URL 'http://localhost:8080/api/v1/praise' also needs to be confirmed against the global baseUrl.
    // final url = 'http://localhost:8080/api/v1/praise'; // Example, actual URL might differ or use global dio's baseUrl

    final praisedMemberId =
        widget.user?.memberId; // ID of the profile being viewed (if not self)
    final praiserId = ref
        .read(authNotifierProvider)
        .user
        ?.memberId; // Current logged-in user's ID

    if (praiserId == null || praisedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사용자 정보를 가져올 수 없습니다.")),
      );
      return;
    }

    final requestBody = {
      // TODO: Replace hardcoded values with dynamic data
      "praisedMemberId":
          praisedMemberId, // Placeholder, this should be the ID of the user whose profile is being viewed.
      "praiserId":
          praiserId, // Placeholder, this should be the current logged-in user's ID.
      "tradeId": 1, // Placeholder, this should be a relevant trade ID.
      "isBuyer": true, // Placeholder
      "praiseCategory": [1, 2], // Placeholder
      "customContent": "정말 좋은 거래였습니다!" // Placeholder
    };

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("TODO: '매너 칭찬하기' 기능은 Repository를 사용하도록 수정해야 합니다.")),
    );

    // try {
    //   // final response = await _dio.post( // This _dio is removed
    //   //   url,
    //   //   data: requestBody,
    //   //   options: Options(headers: {'Content-Type': 'application/json'}),
    //   // );
    //   // ... (rest of the logic) ...
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("네트워크 오류가 발생했습니다.")),
    //   );
    // }
  }

  // 초기 데이터를 가져오는 함수 (앱 시작 시 호출)
  Future<void> _fetchInitialData() async {
    // Attempt to use data passed via widget.user first
    // SessionUser model needs to be updated to include mannerScore, retransactionRate, userCode
    if (widget.user != null) {
      setState(() {
        // These will only work if SessionUser has these fields.
        // _currentMannerScore = widget.user?.mannerScore ?? 50;
        // _retransactionRate = widget.user?.retransactionRate ?? 0;
        // For now, keep defaults or use placeholders as SessionUser might not have these yet
      });
    } else {
      // If user data is not passed or incomplete, try fetching from ProfileNotifier
      // This will update the AuthNotifier's user state, which this widget can then listen to.
      try {
        await ref
            .read(profileNotifierProvider.notifier)
            .fetchMyProfileAndUpdateAuthNotifier();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("초기 프로필 데이터를 불러오는데 실패했습니다: $e")),
        );
      }
    }
  }

  // 새로고침 함수
  Future<void> _onRefresh() async {
    try {
      // Trigger a refresh via ProfileNotifier.
      // This will update AuthNotifier, and this widget (as a consumer) will rebuild.
      await ref
          .read(profileNotifierProvider.notifier)
          .fetchMyProfileAndUpdateAuthNotifier();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("프로필이 새로고침 되었습니다")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("프로필 새로고침에 실패했습니다: $e")),
      );
    }
  }

  static const Color primaryColor = Color(0xFFF96666);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color profileAvatarColor = Color(0xFFF5E6E6);
  static const Color redHeartColor = Colors.red;
  static const Color secondaryTextColor = Colors.grey;
  static const Color dividerColor = Color(0xFFEDE0E0);
  static const Color mainTextColor = Color(0xFF333333);

  static const double horizontalPadding = 20.0;
  static const double verticalSpacing = 24.0;

  @override
  Widget build(BuildContext context) {
    // Watch AuthNotifier to get the user data
    final sessionUser = ref.watch(authNotifierProvider).user;

    // Update local state if sessionUser changes and has the required data
    // This is a common pattern, but be cautious with direct setState in build if not handled carefully.
    // It's often better to derive these directly in the build method or use a separate listener.
    // For now, we assume _fetchInitialData and _onRefresh handle the state updates.
    // if (sessionUser != null) {
    //   _currentMannerScore = sessionUser.mannerScore ?? _currentMannerScore;
    //   _retransactionRate = sessionUser.retransactionRate ?? _retransactionRate;
    // }

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
        actions: [],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildProfileSection(sessionUser), // Pass sessionUser
                const SizedBox(height: verticalSpacing),
                _buildRateSection(),
                const SizedBox(height: verticalSpacing),
                _buildListTile(
                  title: "판매 물품",
                  subTitle: "판매 중인 물품이 없습니다", // TODO: Dynamic data
                  onTap: () {},
                ),
                const SizedBox(height: verticalSpacing),
                _buildListTile(
                  title: "받은 매너 평가",
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _buildMannerSection(
                    sessionUser), // Pass sessionUser for potential data
                const SizedBox(height: verticalSpacing),
                _buildListTile(
                  title: "받은 거래 후기",
                  subTitle: "32", // TODO: Dynamic data
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReviewListScreen()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildReviewSection(),
                const SizedBox(height: verticalSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    // TODO: Fetch actual reviews
    return Column(
      children: [
        _buildReviewComment(
          "꼼꼼하게 확인해주시고, 친절하게 답해주셔서 좋은 거래할 수 있었습니다! 감사합니다.",
          "강아지는야옹",
        ),
        _buildReviewComment(
          "매우 친절하고 쿨거래해주셨어요. 덕분에 좋은 거래 했습니다.",
          "진순이킬러",
        ),
        _buildReviewComment(
          "시간약속 잘지켜주시고 친절하세요. 믿고 거래할 수 있는 분입니다. 추천드려요!",
          "대머리도사",
        ),
      ],
    );
  }

  Widget _buildReviewComment(String text, String author) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomWidget.buildTitle(text,
              size: 14, color: mainTextColor, weight: FontWeight.normal),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomWidget.buildTitle("- $author",
                  size: 12, color: secondaryTextColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(SessionUser? currentUser) {
    // Accept SessionUser
    // TODO: Use actual data from currentUser for name, userCode, profile image etc.
    // String displayName = currentUser?.name ?? widget.user?.name ?? "사용자 이름";
    // String userCodeDisplay = currentUser?.userCode ?? widget.user?.userCode ?? "#xxxxxxx";
    // String profileImageUrl = currentUser?.profileImageUrl ?? widget.user?.profileImageUrl;

    String displayName = currentUser?.name ?? "바보임당"; // Placeholder
    String userCodeDisplay =
        "#zsswie5"; // Placeholder for user code, e.g., currentUser?.userCode

    return Container(
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
              // TODO: Display actual profile image if available
              const CircleAvatar(
                radius: 40,
                backgroundColor: profileAvatarColor,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: secondaryTextColor),
                ),
                child:
                    Icon(Icons.camera_alt, color: secondaryTextColor, size: 16),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.buildTitle(displayName, // Use dynamic name
                    size: 20,
                    weight: FontWeight.w700),
                CustomWidget.buildTitle(
                    userCodeDisplay, // Use dynamic user code
                    size: 14,
                    color: secondaryTextColor),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isPraiseButtonEnabled ? _addPraise : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: _isPraiseButtonEnabled
                                  ? primaryColor
                                  : Colors.grey),
                          backgroundColor: _isPraiseButtonEnabled
                              ? primaryColor
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: CustomWidget.buildTitle("매너 칭찬하기",
                            size: 12,
                            color: backgroundColor,
                            weight: FontWeight.normal),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {}, // TODO: Implement "모아보기"
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primaryColor),
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: CustomWidget.buildTitle("모아보기",
                            size: 12,
                            color: backgroundColor,
                            weight: FontWeight.normal),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateSection() {
    // TODO: Use actual data for rates if available from SessionUser
    // For example: String mannerScoreText = "${_currentMannerScore}%";
    return Row(
      children: [
        Expanded(
          child: _buildRateBox(
            icon: Icons.favorite,
            rate:
                "${_currentMannerScore}", // Display dynamic manner score (needs to be string)
            text: "매너온도", // Or "매너점수"
            subText: "표시될 설명", // E.g., based on score ranges
            iconColor: redHeartColor,
            textColor: primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRateBox(
            icon: Icons.wechat,
            rate:
                "${_retransactionRate}%", // Display dynamic retransaction rate
            text: "재거래희망률",
            subText:
                "보통 30분 이내 응답", // TODO: This subText might be for response rate, not re-transaction
            iconColor: primaryColor,
            textColor: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMannerSection(SessionUser? currentUser) {
    // TODO: Fetch and display actual manner praises
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMannerRow(
            icon: Icons.favorite,
            count: 8, // Dynamic data
            text: "친절하고 매너가 좋아요.",
            iconColor: redHeartColor),
        _buildMannerRow(
            icon: Icons.access_time_filled,
            count: 5, // Dynamic data
            text: "시간 약속을 잘 지켜요.",
            iconColor: mainTextColor),
        _buildMannerRow(
            icon: Icons.wechat_rounded,
            count: 5, // Dynamic data
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
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
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
            Icon(Icons.arrow_forward_ios, size: 16, color: secondaryTextColor),
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
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
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
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CustomWidget.buildTitle(text,
                size: 12, color: mainTextColor, weight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
