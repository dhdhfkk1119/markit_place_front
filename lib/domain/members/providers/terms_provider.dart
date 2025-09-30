import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../_core/utils/my_http.dart'; // dioProvider를 가져오기 위해 임포트
import '../models/term.dart';
import '../repositories/terms_repository.dart';

// TermsRepository가 dioProvider를 사용하도록 수정
final termsRepositoryProvider = Provider<TermsRepository>((ref) {
  // my_http.dart에 있는 중앙 dioProvider를 참조합니다.
  final dio = ref.watch(dioProvider);
  // 생성된 Dio 인스턴스를 TermsRepository에 전달합니다.
  return TermsRepository(dio: dio);
});

/// 약관 목록을 비동기적으로 가져옵니다.
final termsListProvider = FutureProvider<List<Term>>((ref) {
  final repository = ref.watch(termsRepositoryProvider);
  return repository.fetchTermsList();
});
