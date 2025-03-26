class Word {
  int? id;
  String? key;
  String? file;
  String? pronun;
  String? syllables;
  String? text;
  String? isPriority;
  String? cat;
  String? localPath;
  int? isFav;
  bool? isPlaying = false;

  Word(
      {this.file,
      this.pronun,
      this.syllables,
      this.text,
      this.isFav,
      this.localPath,
      this.isPlaying,
      this.cat,
      this.isPriority});

  // Word.fromSnapshot(DataSnapshot snapshot)
  //     : key = snapshot.key,
  //       file = snapshot.child('file') ?? "",
  //       pronun = snapshot.child('pronun') ?? "",
  //       syllables = snapshot.child('syllables') ?? "",
  //       text = snapshot.child('text') ?? "";

  Word.fromMap(Map<String, dynamic> map) {
    this.file = map['file'];
    this.pronun = map['pronun'];
    this.syllables = map['syllables'];
    this.text = map['text'];
    this.isPriority = map['isPriority'];
    this.isFav = map['isFav'];
    this.localPath = map['localPath'];
    this.isPlaying = map['isPlaying'];
    this.cat = map['cat'];
  }

  toJson() {
    return {
      "file": file,
      "pronun": pronun,
      "syllables": syllables,
      "text": text,
      "isPriority": isPriority,
      "id": id,
      "isFav": isFav,
      "cat": cat,
      "localPath": localPath,
    };
  }
}
