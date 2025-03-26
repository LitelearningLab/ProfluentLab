import 'dart:convert';

PronunciationWeeksModel pronunciationWeeksModelFromJson(String str) =>
    PronunciationWeeksModel.fromJson(json.decode(str));

String pronunciationWeeksModelToJson(PronunciationWeeksModel data) => json.encode(data.toJson());

class PronunciationWeeksModel {
  List<Datum>? data;
  bool? status;

  PronunciationWeeksModel({
    this.data,
    this.status,
  });

  factory PronunciationWeeksModel.fromJson(Map<String, dynamic> json) => PronunciationWeeksModel(
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "status": status,
      };
}

class Datum {
  String? weekStart;
  double? totalpracticecount;
  double? totallisteningcount;
  String? userid;
  double? averageSuccessRate;

  Datum({
    this.weekStart,
    this.totalpracticecount,
    this.totallisteningcount,
    this.userid,
    this.averageSuccessRate,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        weekStart: json["weekStart"] ?? "",
        totalpracticecount: json["totalpracticecount"].toDouble() ?? 0.0,
        totallisteningcount: json["totallisteningcount"].toDouble() ?? 0.0,
        userid: json["userid"] ?? "",
        averageSuccessRate: json["averageSuccessRate"]?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "weekStart": weekStart,
        "totalpracticecount": totalpracticecount,
        "totallisteningcount": totallisteningcount,
        "userid": userid,
        "averageSuccessRate": averageSuccessRate,
      };
}
