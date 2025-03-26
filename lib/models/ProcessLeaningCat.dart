
class ProcessLeaningCat {
  String? id;
  String? key;
  String? image;
  String? text;
  String? url;

  ProcessLeaningCat(this.id, this.image, this.text, this.url);

  toJson() {
    return {"image": image, "text": text, "url": url};
  }
}
