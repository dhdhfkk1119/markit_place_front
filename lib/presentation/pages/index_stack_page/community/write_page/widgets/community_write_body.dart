import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/community/community_dto/community_post_write_dto.dart';
import '../../../../../../domain/community/community_provider/community_post_write_notifier.dart';
import 'community_write_item.dart';

class CommunityWriteBody extends ConsumerStatefulWidget {
  const CommunityWriteBody({super.key});

  @override
  ConsumerState<CommunityWriteBody> createState() => _CommunityWriteBodyState();
}

class _CommunityWriteBodyState extends ConsumerState<CommunityWriteBody> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrls = <String>[];
  String _selectedCategoryName = "게시글 주제를 선택해주세여";
  int _topicId = -1;

  void _updateCategory(String categoryName, int topicId) {
    setState(() {
      _selectedCategoryName = categoryName;
      _topicId = topicId;
    });
  }

  void _updateImages(List<String?> newUrls) {
    setState(() {
      _imageUrls.clear();
      _imageUrls.addAll(newUrls.whereType<String>());
    });
  }

  Future<void> _createPost() async {
    final notifier = ref.read(communityPostWriteProvider.notifier);

    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _topicId == -1) {
      CustomWidget.showToast("제목, 내용, 주제를 모두 입력해주세요.");
      return;
    }

    try {
      final postData = CommunityPostWriteDTO(
        title: _titleController.text,
        content: _descriptionController.text,
        location: "임시 위치",
        topicId: _topicId,
        images: _imageUrls,
      );

      await notifier.createPost(postData);
      CustomWidget.showToast("게시글이 성공적으로 작성되었습니다.");
      Navigator.pop(context);
    } catch (e) {
      CustomWidget.showToast("게시글 작성 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomWidget.buildIcon(
          onPressed: () {
            Navigator.pop(context);
          },
          Icon(CupertinoIcons.back),
        ),
        title: CustomWidget.buildTitle("내 게시물 작성하기",
            color: Colors.deepPurpleAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CommunityWriteItem(
          titleController: _titleController,
          descriptionController: _descriptionController,
          selectedCategoryName: _selectedCategoryName,
          imageList: _imageUrls,
          onUpdateCategory: _updateCategory,
          onUpdateImages: _updateImages,
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      margin: EdgeInsets.all(16.0),
      color: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: _createPost,
          child: CustomWidget.buildTitle("작성완료", color: Colors.white, size: 20),
          style: TextButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
          ),
        ),
      ),
    );
  }
}
