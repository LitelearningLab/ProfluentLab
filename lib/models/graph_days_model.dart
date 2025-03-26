import 'dart:convert';

DaysModel daysModelFromJson(String str) => DaysModel.fromJson(json.decode(str));

String daysModelToJson(DaysModel data) => json.encode(data.toJson());

class DaysModel {
  List<Datum>? data;
  bool? status;

  DaysModel({
    this.data,
    this.status,
  });

  factory DaysModel.fromJson(Map<String, dynamic> json) => DaysModel(
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
  double? totalpracticeCount;
  double? averagescore;

  Datum({
    this.totallisteningcount,
    this.userid,
    this.date,
    this.totalpracticeCount,
    this.averagescore,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        totallisteningcount: json["totallisteningcount"].toDouble() ?? 0.0,
        userid: json["userid"] ?? "",
        date: json["date"] ?? "",
        totalpracticeCount: json["totalpracticeCount"].toDouble() ?? 0.0,
        averagescore: json["averagescore"].toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "totallisteningcount": totallisteningcount,
        "userid": userid,
        "date": date,
        "totalpracticeCount": totalpracticeCount,
        "averagescore": averagescore,
      };
}
