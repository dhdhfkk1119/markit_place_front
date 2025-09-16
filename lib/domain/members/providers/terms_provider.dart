import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markit_place_front/_core/utils/error_utils.dart'; // error_utils.dart 임포트 (필요한 경우)
import 'package:markit_place_front/domain/members/models/term.dart';
import 'package:markit_place_front/domain/members/repositories/terms_repository.dart';

final termsRepositoryProvider = Provider<TermsRepository>((ref) {
  return TermsRepository();
});

// 약관 목록을 비동기적으로 가져오는 FutureProvider
// TermsRepository.fetchTermsList()가 이제 List<Term>을 직접 반환하거나 Exception을 throw함
final termsListProvider = FutureProvider<List<Term>>((ref) async {
  final repository = ref.watch(termsRepositoryProvider);
  // fetchTermsList가 List<Term>을 반환하거나 실패 시 Exception을 throw하므로,
  // try-catch가 필수는 아니지만, 여기서 특정 로직을 추가하고 싶다면 사용할 수 있음.
  // Riverpod의 FutureProvider는 Future에서 발생하는 예외를 자동으로 AsyncValue.error로 변환함.
  try {
    final List<Term> terms = await repository.fetchTermsList();
    return terms;
  } catch (e) {
    // 여기서 extractErrorMessage를 사용하여 에러 메시지를 가공할 수도 있지만,
    // UI 단에서 error 객체를 받아 extractErrorMessage를 사용하는 것이 더 일반적일 수 있음.
    // 만약 여기서 에러 메시지를 가공하고 싶다면:
    // final String errorMessage = extractErrorMessage(e);
    // throw Exception(errorMessage);
    // 또는 그냥 재throw 하여 UI에서 처리:
    rethrow; // Riverpod이 이 예외를 AsyncValue.error(e, stackTrace)로 변환
  }
});
