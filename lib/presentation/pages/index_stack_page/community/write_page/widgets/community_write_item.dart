// community_write_item.dart 파일 내용

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import '../../../../../../_core/constants/assets.dart';

class CommunityWriteItem extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final ValueChanged<List<String?>> onImageChanged;
  final ValueChanged<String> onCategorySelected;
  final List<String?> imageList;

  const CommunityWriteItem({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.onImageChanged,
    required this.onCategorySelected,
    required this.imageList,
  });

  @override
  State<CommunityWriteItem> createState() => _CommunityWriteItemState();
}

class _CommunityWriteItemState extends State<CommunityWriteItem> {
  // 상태 관리를 위해 필요한 변수만 남깁니다.
  String _categoryTitle = "게시글 주제를 선택해주세여";
  final int _maxImageUpload = 10;

  final Map<String, bool> _placeFilters = {
    '맛집': false,
    '생활/편의': false,
    '병원/약국': false,
    '미용': false,
  };
  final Map<String, bool> _neighborFilters = {
    '반려동물': false,
    '운동': false,
    '동네친구': false,
    '고민사연': false,
    '취미': false,
    '동네풍경': false,
  };
  final Map<String, bool> _noticeFilters = {
    '동네행상': false,
    '분실/실종': false,
    '동네사건사고': false,
  };

  Future<void> _uploadImage() async {
    // 이미지 리스트 길이를 상위 위젯에서 받아온 값으로 확인
    if (widget.imageList.length >= _maxImageUpload) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // 새로운 이미지 경로를 기존 리스트에 추가
      List<String?> updatedList = List.from(widget.imageList)..add(pickedFile.path);
      // 콜백 함수를 호출하여 상위 위젯의 상태를 업데이트
      widget.onImageChanged(updatedList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildAiController(),
        _buildImageUpload(),
        _buildProductInfo(),
      ],
    );
  }

  Widget _buildAiController() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
            width: double.infinity,
            child: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Icon(
                        CupertinoIcons.staroflife_fill,
                        size: 14,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: "안내 ",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: Assets.Fonts.cookieRun,
                      fontWeight: FontWeight.w700,
                      color: Colors.redAccent,
                    ),
                  ),
                  TextSpan(
                    text:
                    "중고거래 관련 명예훼손, 광고/홍보 목적의 글은 올리실수 없습니다 !추후 제제를 당할 수 있습니다!",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: Assets.Fonts.cookieRun,
                      fontWeight: FontWeight.w200,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildImageUpload() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Add image button (only shown if not at max)
          if (widget.imageList.length < _maxImageUpload)
            InkWell(
              onTap: _uploadImage,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.camera_fill,
                      size: 24,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${widget.imageList.length}/$_maxImageUpload",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(
            width: 15,
          ),
          ...widget.imageList.map((imagePath) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(File(imagePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: CustomWidget.buildTitle("제목", size: 14),
        ),
        TextField(
          controller: widget.titleController, // `widget`을 통해 상위 위젯의 컨트롤러에 접근
          decoration: InputDecoration(
              hintText: '제목',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0))),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: CustomWidget.buildTitle("자세한 설명", size: 14),
        ),
        TextField(
          maxLines: null,
          minLines: 5,
          controller: widget.descriptionController, // `widget`을 통해 상위 위젯의 컨트롤러에 접근
          decoration: InputDecoration(
              hintText:
              '여기는 게시물에 대한 정보가 담기는 필드입니다,여기는 게시물에 대한 정보가 담기는 필드입니다,여기는 게시물에 대한 정보가 담기는 필드입니다,여기는 게시물에 대한 정보가 담기는 필드입니다',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0))),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: IntrinsicWidth(
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) {
                    return _buildAppUpdatePop(context, "카테고리를 선택해주시기바랍니다");
                  },
                );
              },
              child: Row(
                children: [
                  CustomWidget.buildTitle("$_categoryTitle",
                      size: 16, weight: FontWeight.w500),
                  SizedBox(
                    width: 8,
                  ),
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: 20,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppUpdatePop(BuildContext context, String? title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 카테고리 정보
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Row(
              children: [
                Icon(Icons.title, size: 24, color: Colors.deepPurpleAccent),
                CustomWidget.buildTitle("$title", size: 18),
              ],
            ),
          ),
          // 카테고리를 나타내는 영역 위에서 부터 1, 2, 3
          _buildFilterCategory(
              CupertinoIcons.house_alt_fill, "동네정보", _placeFilters),
          _buildFilterCategory(Icons.people, "이웃과 함께", _neighborFilters),
          _buildFilterCategory(
              CupertinoIcons.speaker_zzz_fill, "공지사항", _noticeFilters),
          // 직접 만든 닫기 버튼
          InkWell(
            onTap: () {
              Navigator.pop(context); // 바텀시트 닫기
            },
            child: Padding(
              // 이 부분을 원하는 패딩 값으로 조절하세요.
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  // 아이콘과 텍스트의 간격을 조절
                  Icon(
                    Icons.close,
                    color: Colors.grey,
                    weight: 20,
                  ),
                  const SizedBox(width: 32), // leading 위젯과의 기본 간격과 유사
                  CustomWidget.buildTitle("닫기"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // 필터 그룹을 재사용할 수 있는 메서드
  Widget _buildFilterCategory(
      IconData iconData, String title, Map<String, bool> filters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(iconData, color: Colors.deepPurpleAccent),
            CustomWidget.buildTitle(title, weight: FontWeight.w200, size: 16),
          ],
        ),
        const SizedBox(height: 8),
        // Row 대신 Wrap을 사용하여 자동으로 줄바꿈 처리
        Wrap(
          spacing: 8.0, // 버튼 사이의 가로 간격
          runSpacing: 8.0, // 줄 사이의 세로 간격
          children: filters.entries.map((entry) {
            return _buildListItem(entry.key);
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 각 필터 항목(버튼)
  Widget _buildListItem(String text) {
    bool isSelected = _categoryTitle == text;

    return TextButton(
      onPressed: () {
        // 콜백 함수를 호출하여 상위 위젯의 상태를 업데이트
        widget.onCategorySelected(text);
        setState(() {
          _categoryTitle = text;
          Navigator.pop(context);
        });
      },
      child: CustomWidget.buildTitle(text,
          color: isSelected ? Colors.white : Colors.black,
          weight: FontWeight.w200,
          size: 14),
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Colors.black : Colors.white,
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12),
        // 버튼의 최소 크기를 자식 위젯에 맞게 줄입니다.
        minimumSize: Size.zero,
        // 터치 영역을 위젯 크기에 맞춰 줄입니다.
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}