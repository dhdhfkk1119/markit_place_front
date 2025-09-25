import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../_core/constants/custom_widget.dart';
import '../community_dto/community_post_write_dto.dart';
import '../community_repository/community_post_write_repositroy.dart';
import 'community_list_notifier.dart';

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
  final Ref _ref;

  CommunityPostWriteNotifier(this._repository, this._ref)
      : super(CommunityPostWriteState());

  Future<void> createPost(CommunityPostWriteDTO postData) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      List<String> base64Images = await _convertImageToBase64(postData.images);

      final newPostData = postData.copyWith(images: base64Images);

      await _repository.createPost(newPostData);
      await _ref.read(communityListProvider.notifier).getCommunityList();

      state = state.copyWith(isLoading: false, isSuccess: true);
      CustomWidget.showToast("게시글이 성공적으로 작성되었습니다");
    } catch (e) {
      state = state.copyWith(isSuccess: false, errorMessage: e.toString());
      CustomWidget.showToast("게시글 작성 실패 : $e");
    }
  }

  Future<void> updatePost(int postId, CommunityPostWriteDTO postData) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      List<String> base64Images = await _convertImageToBase64(postData.images);
      final updatedPostData = postData.copyWith(images: base64Images);

      await _repository.updatePost(postId, updatedPostData);

      _ref
          .read(communityListProvider.notifier).getCommunityList();

      state = state.copyWith(isLoading: false, isSuccess: true);
      CustomWidget.showToast("게시글이 성공적으로 수정되었습니다");
    } catch (e) {
      state = state.copyWith(isSuccess: false, errorMessage: e.toString());
      CustomWidget.showToast("게시글 수정 실패 : $e");
    }
  }

  Future<void> deletePost(int postId) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _repository.deletePost(postId);

      _ref.read(communityListProvider.notifier).removePostFromList(postId);

      state = state.copyWith(isLoading: false, isSuccess: true);
      CustomWidget.showToast("게시글이 성공적으로 삭제되었습니다.");
    } catch (e) {
      state = state.copyWith(isSuccess: false, errorMessage: e.toString());
      CustomWidget.showToast("게시글 삭제 실패 : $e");
    }
  }

  Future<List<String>> _convertImageToBase64(List<dynamic> images) async {
    List<String> base64Images = [];
    for (var image in images) {
      if (image is String) {
        base64Images.add(image);
      } else if (image is File) {
        final bytes = await image.readAsBytes();
        String base64String = base64Encode(bytes);
        base64Images.add(base64String);
      } else if (image is XFile) {
        final bytes = await image.readAsBytes();
        String base64String = base64Encode(bytes);
        base64Images.add(base64String);
      }
    }
    return base64Images;
  }
}

final communityPostWriteRepositoryProvider =
    Provider<CommunityPostWriteRepository>((ref) {
  final dio = Dio();
  return CommunityPostWriteRepository(dio);
});

final communityPostWriteProvider =
    StateNotifierProvider<CommunityPostWriteNotifier, CommunityPostWriteState>(
        (ref) {
  final repository = ref.read(communityPostWriteRepositoryProvider);
  return CommunityPostWriteNotifier(repository, ref);
});
