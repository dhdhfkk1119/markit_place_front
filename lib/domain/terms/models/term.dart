// lib/domain/terms/models/term.dart

class Term {
  final int id;
  final String title;
  final String content;
  final bool required; // 서버 응답의 'required' 필드에 맞춤

  Term({
    required this.id,
    required this.title,
    required this.content,
    required this.required,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      required: json['required'] as bool,
    );
  }

  // (선택적) toJson 메소드 - 만약 클라이언트에서 Term 객체를 JSON으로 변환할 필요가 있다면
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'required': required,
    };
  }
}
