import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/community/list_page/widgets/community_filter_list.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/community/write_page/community_write_page.dart';

import '../../../../../../_core/constants/custom_widget.dart';
import 'community_list_item.dart';

// 재사용 가능한 스타일 정의
const _titleTextStyle =
    TextStyle(fontFamily: "CookieRun", fontWeight: FontWeight.w500);

class CommunityListBody extends StatefulWidget {
  const CommunityListBody({super.key});

  @override
  State<CommunityListBody> createState() => _CommunityListBodyState();
}

class _CommunityListBodyState extends State<CommunityListBody>
    with TickerProviderStateMixin {
  bool _isFilterVisible = false;
  String _currentTitle = "부전제2동";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // AppBar 위젯을 그리는 부분
  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: _buildTitleRow(),
      actions: [
        _buildActionButton(CupertinoIcons.list_bullet, () {
          setState(() {
            _isFilterVisible = !_isFilterVisible;
          });
        }),
        _buildActionButton(CupertinoIcons.profile_circled, () {}),
        _buildActionButton(CupertinoIcons.search, () {}),
        _buildActionButton(CupertinoIcons.bell_fill, () {}),
      ],
    );
  }

  // 타이틀 부분을 별도의 위젯으로 분리
  Widget _buildTitleRow() {
    return Row(
      children: [
        Text(_currentTitle, style: _titleTextStyle),
        const SizedBox(width: 4),
        _buildLocationDropdown(),
      ],
    );
  }

  // 드롭다운 타이틀 메뉴를 별도의 위젯으로 분리
  Widget _buildLocationDropdown() {
    return InkWell(
      onTap: () {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(Offset.zero);

        showGeneralDialog(
          context: context,
          barrierColor: Colors.black54, // <-- 이 부분이 배경을 반투명 회색으로 만듭니다.
          barrierDismissible: true, // 배경을 탭하면 팝업이 닫히게 합니다.
          barrierLabel: "Dialog",
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, anim1, anim2) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: offset.dx,
                    top: offset.dy + 100,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IntrinsicWidth(
                          // 팝업 너비를 자식 위젯에 맞춥니다.
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildPlacePopupItem(context, '부전제1동'),
                              _buildPlacePopupItem(context, '부전제2동'),
                              _buildPlacePopupItem(context, '부전제3동'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ).then((value) {
          if (value != null) {
            setState(() {
              _currentTitle = value as String;
            });
          }
        });
      },
      child: const Icon(CupertinoIcons.chevron_down, size: 15.0),
    );
  }

  // 바디 부분을 별도의 메서드로 분리
  Widget _buildBody() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Stack(
          // ✨ Stack 추가
          children: [
            Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation);
                    return ClipRect(
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: _isFilterVisible
                      ? ConstrainedBox(
                          key: ValueKey(true),
                          constraints: BoxConstraints(maxWidth: 155),
                          child: CommunityFilterList(),
                        )
                      : const SizedBox.shrink(key: ValueKey(false)),
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: ListView.separated(
                      itemCount: 10,
                      itemBuilder: (BuildContext context, int index) {
                        return CommunityListItem(_isFilterVisible);
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            _buildWriteButton(),
          ],
        ),
      ),
    );
  }

  // 아이콘 버튼을 만드는 함수
  IconButton _buildActionButton(IconData iconData, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(iconData),
    );
  }

  // PopupMenuItem을 만드는 함수
  Widget _buildPlacePopupItem(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop(title);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "CookieRun",
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWriteButton() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Center(
        child: Container(
          // 타원형 디자인 설정
          decoration: BoxDecoration(
            color: Colors.white, // 배경색
            borderRadius: BorderRadius.circular(30.0), // 타원형을 만들기 위해 둥근 모서리 설정
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // 그림자 위치
              ),
            ],
          ),
          padding:
              EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0), // 내부 여백
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CommunityWritePage()));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min, // Row의 크기를 자식 위젯에 맞춤
              children: [
                Icon(
                  CupertinoIcons.plus,
                  size: 20,
                  color: Colors.deepPurpleAccent,
                ),
                const SizedBox(
                  width: 10,
                ),
                CustomWidget.buildTitle(
                  "글쓰기",
                  color: Colors.deepPurpleAccent,
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
