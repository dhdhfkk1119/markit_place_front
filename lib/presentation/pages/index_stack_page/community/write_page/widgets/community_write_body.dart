// community_write_body.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markit_place_front/_core/constants/custom_widget.dart';
import 'package:markit_place_front/domain/community/community_dto/community_post_write_dto.dart';
import 'package:markit_place_front/domain/community/community_repository/community_post_write_repositroy.dart';
import 'package:markit_place_front/presentation/pages/index_stack_page/community/write_page/widgets/community_write_item.dart';

class CommunityWriteBody extends StatefulWidget {
  const CommunityWriteBody({super.key});

  @override
  State<CommunityWriteBody> createState() => _CommunityWriteBodyState();
}

class _CommunityWriteBodyState extends State<CommunityWriteBody> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = "";
  final List<String?> _imageList = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
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
        actions: [
          // 오른쪽에 붙이는 아이콘
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CommunityWriteItem(
          titleController: _titleController,
          descriptionController: _descriptionController,
          // 콜백 함수와 이미지 리스트를 전달합니다.
          onImageChanged: (newImageList) {
            setState(() {
              _imageList.clear();
              _imageList.addAll(newImageList);
            });
          },
          onCategorySelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
          imageList: _imageList,
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
          onPressed: () async {
            final String title = _titleController.text;
            final String content = _descriptionController.text;
            final location = "111"; // 예시
            final topicId = 1; // 예시

            // `_imageList` 상태 변수를 사용하도록 수정
            final images = _imageList.whereType<String>().toList();

            final postData = CommunityPostWriteDTO(
              title: title,
              content: content,
              location: location,
              topicId: topicId,
              images: images,
            );

            final repository = CommunityPostWriteRepository();
            try {
              await repository.createPost(postData);
              Navigator.pop(context);
              // TODO - 새로 고침 추가 해야함
            } catch (e) {
              print('게시글 작성 실패 : $e');
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('게시글 작성에 실패했습니다')));
            }
          },
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