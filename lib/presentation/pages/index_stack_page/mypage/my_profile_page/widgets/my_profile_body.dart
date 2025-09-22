import 'package:flutter/material.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../_core/dtos/api_service.dart';
import '../review_list_screen.dart';
import 'package:dio/dio.dart';

class MyProfileBody extends StatefulWidget {
  final user;
  const MyProfileBody({required this.user, super.key});

  @override
  State<MyProfileBody> createState() => _MyProfileBodyState();
}

class _MyProfileBodyState extends State<MyProfileBody> {
  int _currentMannerScore = 50;
  int _retransactionRate = 0;
  bool _isPraiseButtonEnabled = true;

  final Dio _dio = Dio();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  // 매너 칭찬하기
  Future<void> _addPraise() async {
    if (!_isPraiseButtonEnabled) return;

    final url = 'http://localhost:8080/api/v1/praise';

    // 사용자 ID와 거래 ID로 대체
    final requestBody = {
      "praisedMemberId": 1,
      "praiserId": 2,
      "tradeId": 1,
      "isBuyer": true,
      "praiseCategory": [1, 2],
      "customContent": "정말 좋은 거래였습니다!"
    };

    try {
      final response = await _dio.post(
        url,
        data: requestBody,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['isSuccess']) {
          setState(() {
            _currentMannerScore = responseData['updatedMannerScore'];
            _retransactionRate = responseData['updatedRetransactionRate'];
            _isPraiseButtonEnabled = false; // 성공 시 버튼 비활성화
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(responseData['message']),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("매너 칭찬에 실패했습니다. 다시 시도해주세요.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("네트워크 오류가 발생했습니다.")),
      );
    }
  }

  // 초기 데이터를 가져오는 함수 (앱 시작 시 호출)
  Future<void> _fetchInitialData() async {
    try {
      final int memberId = 1; //실제 로그인 사용자의 ID를 넣어줘야함
      final latestProfile = await _apiService.fetchUserProfile(memberId);

      // 상태 업데이트
      setState(() {
        _currentMannerScore = latestProfile.mannerScore;
        _retransactionRate = latestProfile.retransactionRate;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("초기 프로필 데이터를 불러오는데 실패했습니다")),
      );
    }
  }

  // 새로고침 함수
  Future<void> _onRefresh() async {
    try {
      final int memberId = 1;
      final latestProfile = await _apiService.fetchUserProfile(memberId);

      setState(() {
        _currentMannerScore = latestProfile.mannerScore;
        _retransactionRate = latestProfile.retransactionRate;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("프로필이 새로고침 되었습니다")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("프로필 새로고침에 실패했습니다: $e")),
      );
    }

    await Future.delayed(const Duration(seconds: 1));
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
                // 프로필 섹션
                _buildProfileSection(),
                const SizedBox(height: verticalSpacing),

                // 재거래 및 응답률 섹션
                _buildRateSection(),
                const SizedBox(height: verticalSpacing),

                // 판매 물품 섹션
                _buildListTile(
                  title: "판매 물품",
                  subTitle: "판매 중인 물품이 없습니다",
                  onTap: () {},
                ),
                const SizedBox(height: verticalSpacing),

                // 받은 매너 평가 섹션
                _buildListTile(
                  title: "받은 매너 평가",
                  onTap: () {},
                ),
                const SizedBox(height: 10),

                _buildMannerSection(),
                const SizedBox(height: verticalSpacing),

                // 받은 거래 후기 섹션
                _buildListTile(
                  title: "받은 거래 후기",
                  subTitle: "32",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReviewListScreen()),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // 거래 후기 댓글
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

  Widget _buildProfileSection() {
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
                CustomWidget.buildTitle("바보임당",
                    size: 20, weight: FontWeight.w700),
                CustomWidget.buildTitle("#zsswie5",
                    size: 14, color: secondaryTextColor),
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
                        onPressed: () {},
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
    return Row(
      children: [
        Expanded(
          child: _buildRateBox(
            icon: Icons.favorite,
            rate: "90%",
            text: "평균 평점",
            subText: "9명 중 8명 만족",
            iconColor: redHeartColor,
            textColor: primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRateBox(
            icon: Icons.wechat,
            rate: "80%",
            text: "응답률",
            subText: "보통 30분 이내 응답",
            iconColor: primaryColor,
            textColor: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMannerSection() {
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
