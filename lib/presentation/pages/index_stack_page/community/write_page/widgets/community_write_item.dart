import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../_core/constants/assets.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/community/community_provider/community_category_notifier.dart';

class CommunityWriteItem extends ConsumerStatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<dynamic> imageList;
  final String selectedCategoryName;
  final ValueChanged<List<dynamic>> onUpdateImages;
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

  @override
  ConsumerState<CommunityWriteItem> createState() => _CommunityWriteItemState();
}

class _CommunityWriteItemState extends ConsumerState<CommunityWriteItem> {
  final int _maxImageUpload = 10;

  Future<void> _uploadImage() async {
    if (widget.imageList.length >= _maxImageUpload) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final updatedList = List<dynamic>.from(widget.imageList)..add(pickedFile);
      widget.onUpdateImages(updatedList);
    }
  }

  void _removeImage(int index) {
    final updatedList = List<dynamic>.from(widget.imageList)..removeAt(index);
    widget.onUpdateImages(updatedList);
  }

  Widget _buildImage(dynamic image) {
    if (image is String) {
      return Image.memory(base64Decode(image), fit: BoxFit.cover);
    } else if (image is XFile) {
      return Image.file(File(image.path), fit: BoxFit.cover);
    }
    return Container();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(communityCategoryProvider).getCategories();
    });
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
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: RichText(
            text: TextSpan(
              children: [
                const WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.only(right: 4.0),
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
                    const Icon(
                      CupertinoIcons.camera_fill,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${widget.imageList.length}/$_maxImageUpload",
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(width: 15),
          ...widget.imageList.asMap().entries.map((entry) {
            final index = entry.key;
            final dynamic imageFile = entry.value;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImage(imageFile),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: InkWell(
                      onTap: () {
                        _removeImage(index);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
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
          controller: widget.titleController,
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
          controller: widget.descriptionController,
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
                  CustomWidget.buildTitle("${widget.selectedCategoryName}",
                      size: 16, weight: FontWeight.w500),
                  const SizedBox(
                    width: 8,
                  ),
                  const Icon(
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
    final notifier = ref.watch(communityCategoryProvider);

    if (notifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifier.errorMessage != null) {
      return Center(child: Text("에러: ${notifier.errorMessage}"));
    }

    final categories = notifier.categories;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                children: [
                  const Icon(Icons.title,
                      size: 24, color: Colors.deepPurpleAccent),
                  CustomWidget.buildTitle(title ?? "카테고리 선택", size: 18),
                ],
              ),
            ),

            ...categories.map((category) {
              return _buildFilterCategory(
                context,
                Icons.category,
                category.name,
                category.topics,
              );
            }).toList(),

            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.zero,
                child: Row(
                  children: [
                    const Icon(
                      Icons.close,
                      color: Colors.grey,
                      weight: 20,
                    ),
                    const SizedBox(width: 32),
                    CustomWidget.buildTitle("닫기"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFilterCategory(
      BuildContext context,
      IconData iconData,
      String title,
      List<dynamic> topics,
      ) {
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
          children: topics.map((topic) {
            // topic이 DTO 객체이므로 topic.name, topic.id 사용
            return _buildListItem(context, topic.name, topic.id);
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }


  Widget _buildListItem(BuildContext context, String text, int topicId) {
    bool isSelected = widget.selectedCategoryName == text;

    return TextButton(
      onPressed: () {
        widget.onUpdateCategory(text, topicId);
        Navigator.pop(context);
      },
      child: CustomWidget.buildTitle(text,
          color: isSelected ? Colors.white : Colors.black,
          weight: FontWeight.w200,
          size: 14),
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}