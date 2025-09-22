import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../_core/constants/custom_widget.dart';
import '../community_dto/community_post_write_dto.dart';
import '../community_repository/community_post_write_repositroy.dart';

class CommunityPostWriteState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  CommunityPostWriteState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  CommunityPostWriteState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return CommunityPostWriteState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CommunityPostWriteNotifier
    extends StateNotifier<CommunityPostWriteState> {
  final CommunityPostWriteRepository _repository;

  CommunityPostWriteNotifier(this._repository)
      : super(CommunityPostWriteState());

  Future<void> createPost(CommunityPostWriteDTO postData) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      List<String> base64Images = await _convertImageToBase64(postData.images);


      final newPostData = CommunityPostWriteDTO(
        title: postData.title,
        content: postData.content,
        location: postData.location,
        topicId: postData.topicId,
        images: base64Images,
      );

      await _repository.createPost(newPostData);

      state = state.copyWith(isLoading: false, isSuccess: true);
      CustomWidget.showToast("게시글이 성공적으로 작성되었습니다");
    } catch (e) {
      state = state.copyWith(isSuccess: false, errorMessage: e.toString());
      CustomWidget.showToast("게시글 작성 실패 : $e");
    }
  }

  Future<void> updatePost(int postId, CommunityPostWriteDTO postData) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      List<String> base64Images = await _convertImageToBase64(postData.images);
      final updatedPostData = postData.copyWith(images: base64Images);

      await _repository.updatePost(postId, updatedPostData);
      state = state.copyWith(isLoading: false, isSuccess: true);
      CustomWidget.showToast("게시글이 성공적으로 수정되었습니다");
    } catch (e) {
      state = state.copyWith(isSuccess: false, errorMessage: e.toString());
      CustomWidget.showToast("게시글 수정 실패 : $e");
    }
  }

  Future<void> deletePost(int postId) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _repository.deletePost(postId);

      state = state.copyWith(isLoading: false, isSuccess: true);
      CustomWidget.showToast("게시글이 성공적으로 삭제되었습니다.");
    } catch (e) {
      state = state.copyWith(isSuccess: false, errorMessage: e.toString());
      CustomWidget.showToast("게시글 삭제 실패 : $e");
    }
  }




  Future<List<String>> _convertImageToBase64(List<String> imagePaths) async {
    List<String> base64Images = [];
    for (String imagePath in imagePaths) {
      final File imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      String base64String = base64Encode(bytes);
      base64Images.add(base64String);
    }
    return base64Images;
  }
}

final communityPostWriteProvider =
    StateNotifierProvider<CommunityPostWriteNotifier, CommunityPostWriteState>(
        (ref) {
  final dio = Dio();
  final repository = CommunityPostWriteRepository(dio);
  return CommunityPostWriteNotifier(repository);
});
