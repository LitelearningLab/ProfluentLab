class StaticText {
  final int id;
  final String content;

  StaticText({required this.id, required this.content});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
    };
  }

  factory StaticText.fromMap(Map<String, dynamic> map) {
    return StaticText(
      id: map['id'],
      content: map['content'],
    );
  }
}
