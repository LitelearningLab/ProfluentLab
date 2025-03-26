class CloseValue {
  String? isCorrect;
  String? word;
  String? heard;
  double? wordPer;
  List? formatedWords;

  CloseValue({
    this.isCorrect,
    this.heard,
    this.word,
    this.wordPer,
    this.formatedWords,
  });

  CloseValue.map(dynamic obj) {
    this.isCorrect = obj['isCorrect'];
    this.word = obj['word'];
    this.heard = obj['heard'];

    this.wordPer = obj['wordPer'];
    this.formatedWords = obj['formatedWords'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (isCorrect != null) {
      map['isCorrect'] = isCorrect;
    }
    map['word'] = word;
    map['heard'] = heard;

    map['wordPer'] = wordPer;
    map['formatedWords'] = formatedWords;

    return map;
  }

  CloseValue.fromMap(Map<String, dynamic> map) {
    this.isCorrect = map['isCorrect'];
    this.word = map['word'];

    this.wordPer = map['wordPer'];
    this.heard = map['heard'];
    this.formatedWords = map['formatedWords'];
  }
}
