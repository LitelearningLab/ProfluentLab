import 'dart:convert';

MonthsModel monthsModelFromJson(String str) => MonthsModel.fromJson(json.decode(str));

String monthsModelToJson(MonthsModel data) => json.encode(data.toJson());

class MonthsModel {
  List<Datum>? data;
  bool? status;

  MonthsModel({
    this.data,
    this.status,
  });

  factory MonthsModel.fromJson(Map<String, dynamic> json) => MonthsModel(
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
  double? averageScore;
  String? userid;

  Datum({
    this.monthStart,
    this.totalpracticecount,
    this.totallisteningcount,
    this.averageScore,
    this.userid,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        monthStart: json["monthStart"] ?? "",
        totalpracticecount: json["totalpracticecount"].toDouble() ?? 0.0,
        totallisteningcount: json["totallisteningcount"].toDouble() ?? 0.0,
        averageScore: json["averageScore"].toDouble() ?? 0.0,
        userid: json["userid"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "monthStart": monthStart,
        "totalpracticecount": totalpracticecount,
        "totallisteningcount": totallisteningcount,
        "averageScore": averageScore,
        "userid": userid,
      };
}
