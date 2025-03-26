import 'dart:convert';

PronunciationMonthsModel monthsModelFromJson(String str) => PronunciationMonthsModel.fromJson(json.decode(str));

String PronunciationMonthsModelToJson(PronunciationMonthsModel data) => json.encode(data.toJson());

class PronunciationMonthsModel {
  List<Datum>? data;
  bool? status;

  PronunciationMonthsModel({
    this.data,
    this.status,
  });

  factory PronunciationMonthsModel.fromJson(Map<String, dynamic> json) => PronunciationMonthsModel(
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "status": status,
      };
}

class Datum {
  String? monthStart;
  double? totalpracticecount;
  double? totallisteningcount;
  String? userid;
  double? averageCorrect;
  double? averageSuccessRate;

  Datum({
    this.monthStart,
    this.totalpracticecount,
    this.totallisteningcount,
    this.userid,
    this.averageSuccessRate,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        monthStart: json["monthStart"] ?? "",
        totalpracticecount: json["totalpracticecount"].toDouble() ?? 0.0,
        totallisteningcount: json["totallisteningcount"].toDouble() ?? 0.0,
        userid: json["userid"] ?? "",
        averageSuccessRate: json["averageSuccessRate"]?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "monthStart": monthStart,
        "totalpracticecount": totalpracticecount,
        "totallisteningcount": totallisteningcount,
        "userid": userid,
        "averageSuccessRate": averageSuccessRate,
      };
}
