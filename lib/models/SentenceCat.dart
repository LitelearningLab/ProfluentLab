
class SentenceCat {
  String? key;
  String? title;

  SentenceCat({this.title});


  toJson() {
    return {
      "title": title,
    };
  }
}
