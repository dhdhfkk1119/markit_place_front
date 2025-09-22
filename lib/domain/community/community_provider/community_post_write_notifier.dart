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
      List<String> base64Images = [];
      for (String imagePath in postData.images) {
        final File imageFile = File(imagePath);
        final bytes = imageFile.readAsBytes();
        String base64String = base64Encode(bytes as List<int>);
        base64Images.add(base64String);
      }

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
}

final communityPostWriteProvider =
    StateNotifierProvider<CommunityPostWriteNotifier, CommunityPostWriteState>(
        (ref) {
  final dio = Dio();
  final repository = CommunityPostWriteRepository(dio);
  return CommunityPostWriteNotifier(repository);
});
