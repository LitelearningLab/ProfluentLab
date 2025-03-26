class Sentence {
  int? id;
  String? key;
  String? file;
  String? text;
  String? isPriority;
  String? cat;
  String? localPath;
  int? isFav;

  Sentence({this.file, this.text, this.isFav, this.cat, this.localPath, this.isPriority});

  toJson() {
    return {
      "file": file,
      "text": text,
      "id": id,
      "isFav": isFav,
      "cat": cat,
      "isPriority": isPriority,
      "localPath": localPath,
    };
  }
}