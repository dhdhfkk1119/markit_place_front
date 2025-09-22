import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_widget.dart';

class CommunityWriteItem extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<String> imageList;
  final String selectedCategoryName;
  final ValueChanged<List<String?>> onUpdateImages;
  final void Function(String, int) onUpdateCategory;

  const CommunityWriteItem({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.imageList,
    required this.selectedCategoryName,
    required this.onUpdateImages,
    required this.onUpdateCategory,
  });

  final int _maxImageUpload = 10;

  Future<void> _uploadImage() async {
    if (imageList.length >= _maxImageUpload) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final updatedList = List<String?>.from(imageList)..add(pickedFile.path);
      onUpdateImages(updatedList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildAiController(),
        _buildImageUpload(),
        _buildProductInfo(context),
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
          ),
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (imageList.length < _maxImageUpload)
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
                      "${imageList.length}/$_maxImageUpload",
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
          ...imageList.map((imagePath) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(File(imagePath)),
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

  Widget _buildProductInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
          child: CustomWidget.buildTitle("제목", size: 14),
        ),
        TextField(
          controller: titleController,
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
          controller: descriptionController,
          decoration: InputDecoration(
              hintText: '여기는 게시물에 대한 정보가 담기는 필드입니다',
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
                  CustomWidget.buildTitle("$selectedCategoryName",
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
    final Map<String, int> _placeFilters = {
      '맛집': 1,
      '생활/편의': 2,
      '병원/약국': 3,
      '미용': 4
    };
    final Map<String, int> _neighborFilters = {
      '반려동물': 5,
      '운동': 6,
      '동네친구': 7,
      '고민사연': 8,
      '취미': 9,
      '동네풍경': 10
    };
    final Map<String, int> _noticeFilters = {
      '동네행상': 11,
      '분실/실종': 12,
      '동네사건사고': 13
    };

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Row(
              children: [
                Icon(Icons.title, size: 24, color: Colors.deepPurpleAccent),
                CustomWidget.buildTitle("$title", size: 18),
              ],
            ),
          ),
          _buildFilterCategory(
              context, CupertinoIcons.house_alt_fill, "동네정보", _placeFilters),
          _buildFilterCategory(
              context, Icons.people, "이웃과 함께", _neighborFilters),
          _buildFilterCategory(
              context, CupertinoIcons.speaker_zzz_fill, "공지사항", _noticeFilters),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  Icon(
                    Icons.close,
                    color: Colors.grey,
                    weight: 20,
                  ),
                  const SizedBox(width: 32),
                  CustomWidget.buildTitle("닫기"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterCategory(BuildContext context, IconData iconData,
      String title, Map<String, int> filters) {
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
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: filters.entries.map((entry) {
            return _buildListItem(context, entry.key, entry.value);
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildListItem(BuildContext context, String text, int topicId) {
    bool isSelected = selectedCategoryName == text;

    return TextButton(
      onPressed: () {
        onUpdateCategory(text, topicId);
        Navigator.pop(context);
      },
      child: CustomWidget.buildTitle(text,
          color: isSelected ? Colors.white : Colors.black,
          weight: FontWeight.w200,
          size: 14),
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Colors.black : Colors.white,
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
