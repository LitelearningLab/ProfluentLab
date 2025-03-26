import 'dart:convert';

WeeksModel weeksModelFromJson(String str) => WeeksModel.fromJson(json.decode(str));

String weeksModelToJson(WeeksModel data) => json.encode(data.toJson());

class WeeksModel {
  List<Datum>? data;
  bool? status;

  WeeksModel({
    this.data,
    this.status,
  });

  factory WeeksModel.fromJson(Map<String, dynamic> json) => WeeksModel(
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
  double? averageScore;
  String? userid;

  Datum({
    this.weekStart,
    this.totalpracticecount,
    this.totallisteningcount,
    this.averageScore,
    this.userid,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        weekStart: json["weekStart"] ?? "",
        totalpracticecount: json["totalpracticecount"].toDouble() ?? 0.0,
        totallisteningcount: json["totallisteningcount"].toDouble() ?? 0.0,
        averageScore: json["averageScore"].toDouble() ?? 0.0,
        userid: json["userid"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "weekStart": weekStart,
        "totalpracticecount": totalpracticecount,
        "totallisteningcount": totallisteningcount,
        "averageScore": averageScore,
        "userid": userid,
      };
}
