import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../../_core/constants/custom_widget.dart';
import '../../../../../../domain/community/community_dto/community_detail_dto.dart';
import '../../../../../../domain/community/community_dto/community_post_write_dto.dart';
import '../../../../../../domain/community/community_provider/community_list_notifier.dart';
import '../../../../../../domain/community/community_provider/community_post_write_notifier.dart';
import 'community_write_item.dart';

class CommunityWriteBody extends ConsumerStatefulWidget {
  final CommunityDetailDto? dto;

  const CommunityWriteBody({super.key, this.dto});

  @override
  ConsumerState<CommunityWriteBody> createState() => _CommunityWriteBodyState();
}

class _CommunityWriteBodyState extends ConsumerState<CommunityWriteBody> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<dynamic> _imageFiles = [];
  String _selectedCategoryName = "게시글 주제를 선택해주세요";
  int _topicId = -1;
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.dto != null) {
      isEditMode = true;
      _titleController.text = widget.dto!.title;
      _descriptionController.text = widget.dto!.content;
      _selectedCategoryName = widget.dto!.topic;
      _topicId = widget.dto!.topicId ?? -1;

      if (widget.dto!.images != null) {
        _processExistingImages(widget.dto!.images!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateCategory(String categoryName, int topicId) {
    setState(() {
      _selectedCategoryName = categoryName;
      _topicId = topicId;
    });
  }

  void _updateImages(List<dynamic> newImageFiles) {
    setState(() {
      _imageFiles.clear();
      _imageFiles.addAll(newImageFiles);
    });
  }

  Future<List<String>> _getEncodedImages() async {
    final List<String> encodedImages = [];
    for (var image in _imageFiles) {
      if (image is String) {
        encodedImages.add(image);
      } else if (image is XFile) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        encodedImages.add(base64String);
      }
    }
    return encodedImages;
  }

  Future<void> _processExistingImages(List<String> imageUrls) async {
    for (String imageData in imageUrls) {
      if (imageData.startsWith('/9j/')) {
        setState(() {
          _imageFiles.add(imageData);
        });
        print("base64 이미지 처리 완료");
      } else if (imageData.startsWith('http')) {
        try {
          final response = await Dio().get(
            imageData,
            options: Options(responseType: ResponseType.bytes),
          );
          final tempDir = await getTemporaryDirectory();
          final tempFile =
          File('${tempDir.path}/${DateTime.now().toIso8601String()}');
          await tempFile.writeAsBytes(response.data);
          final xFile = XFile(tempFile.path);

          setState(() {
            _imageFiles.add(xFile);
          });
        } catch (e) {
        }
      }
    }
  }

  Future<bool> _createPost() async {
    final notifier = ref.read(communityPostWriteProvider.notifier);
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _topicId == -1) {
      CustomWidget.showToast("제목, 내용, 주제를 모두 입력해주세요.");
      return false;
    }
    try {
      final encodedImages = await _getEncodedImages();
      final postData = CommunityPostWriteDTO(
        title: _titleController.text,
        content: _descriptionController.text,
        location: "임시 위치",
        topicId: _topicId,
        images: encodedImages,
      );
      await notifier.createPost(postData);
      return true;
    } catch (e) {
      CustomWidget.showToast("게시글 작성 실패: $e");
      return false;
    }
  }

  Future<bool> _updatePost() async {
    final notifier = ref.read(communityPostWriteProvider.notifier);
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _topicId == -1) {
      CustomWidget.showToast("제목, 내용, 주제를 모두 입력해주세요.");
      return false;
    }
    try {
      final encodedImages = await _getEncodedImages();
      final updatePostData = CommunityPostWriteDTO(
        title: _titleController.text,
        content: _descriptionController.text,
        location: "임시 위치",
        topicId: _topicId,
        images: encodedImages,
      );
      await notifier.updatePost(widget.dto!.id, updatePostData);
      return true;
    } catch (e) {
      CustomWidget.showToast("게시글 수정 실패 : $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomWidget.buildIcon(
          onPressed: (){
            if (isEditMode) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pop();
            }
          },
          const Icon(CupertinoIcons.back),
        ),
        title: CustomWidget.buildTitle(isEditMode ? "내 게시물 수정하기" : "내 게시물 작성하기",
            color: Colors.deepPurpleAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CommunityWriteItem(
          titleController: _titleController,
          descriptionController: _descriptionController,
          selectedCategoryName: _selectedCategoryName,
          imageList: _imageFiles,
          onUpdateCategory: _updateCategory,
          onUpdateImages: _updateImages,
        ),
      ),
      bottomSheet: _buildSubmitButton(),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      color: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () async {
            ref.refresh(communityListProvider);
            final isSuccess =
            isEditMode ? await _updatePost() : await _createPost();
            if (isSuccess && mounted) {
              if (isEditMode) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop();
              }
            }
          },
          child: CustomWidget.buildTitle(isEditMode ? "수정하기" : "작성완료",
              color: Colors.white, size: 20),
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