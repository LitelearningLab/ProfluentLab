import 'dart:convert';

PronunciationDaysModel pronunciationDaysModelFromJson(String str) => PronunciationDaysModel.fromJson(json.decode(str));

String pronunciationDaysModelToJson(PronunciationDaysModel data) => json.encode(data.toJson());

class PronunciationDaysModel {
  List<Datum>? data;
  bool? status;

  PronunciationDaysModel({
    this.data,
    this.status,
  });

  factory PronunciationDaysModel.fromJson(Map<String, dynamic> json) => PronunciationDaysModel(
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "status": status,
      };
}

class Datum {
  double? totallisteningcount;
  String? userid;
  String? date;
  double? totalpracticecount;
  double? averageSuccessRate;

  Datum({
    this.totallisteningcount,
    this.userid,
    this.date,
    this.totalpracticecount,
    this.averageSuccessRate,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        totallisteningcount: double.parse((json["totallisteningcount"] ?? 0).toString()),
        userid: json["userid"] ?? "",
        date: json["date"] ?? "",
        totalpracticecount: double.parse((json["totalpracticecount"] ?? 0).toString()),
        averageSuccessRate: json["averageSuccessRate"].toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "totallisteningcount": totallisteningcount,
        "userid": userid,
        "date": date,
        "totalpracticeCount": totalpracticecount,
        "averageSuccessRate": averageSuccessRate,
      };
}
