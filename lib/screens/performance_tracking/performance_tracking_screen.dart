import 'dart:convert';
import 'dart:developer';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:litelearninglab/common_widgets/background_widget.dart';
import 'package:litelearninglab/common_widgets/common_app_bar.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/models/graph_days_model.dart';
import 'package:litelearninglab/models/graph_months_model.dart';
import 'package:litelearninglab/models/graph_weeks_model.dart';
import 'package:litelearninglab/models/pronunciation_graph_days_model.dart';
import 'package:litelearninglab/models/pronunciation_graph_months_model.dart';
import 'package:litelearninglab/models/pronunciation_graph_weeks_model.dart';
import 'package:litelearninglab/screens/dashboard/widgets/new_submenu_items.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:toast/toast.dart';

class DataItem {
  int x;
  double y1;
  double y2;
  double y3;
  DataItem({required this.x, required this.y1, required this.y2, required this.y3});
}

class PerformanceTrackingScreen extends StatefulWidget {
  const PerformanceTrackingScreen({Key? key}) : super(key: key);

  @override
  State<PerformanceTrackingScreen> createState() => _PerformanceTrackingScreenState();
}

class _PerformanceTrackingScreenState extends State<PerformanceTrackingScreen> {
  @override
  void initState() {
    graphForSentenceAndCallFlow(type: '5 days');
    graphForPronunciationAndSounds(type: '5 days');
    super.initState();
  }

  DaysModel _daysResponse = DaysModel.fromJson({});
  WeeksModel _weeksResponse = WeeksModel.fromJson({});
  MonthsModel _monthResponse = MonthsModel.fromJson({});

  PronunciationDaysModel _pronunciationDaysResponse = PronunciationDaysModel.fromJson({});
  PronunciationWeeksModel _pronunciationWeeksResponse = PronunciationWeeksModel.fromJson({});
  PronunciationMonthsModel _pronunciationMonthsResponse = PronunciationMonthsModel.fromJson({});

  PageController _pageController = PageController();
  int activePage = 0;

  String selectedTimePeriod = '5 days';
  String PronunciationSelectedTimePeriod = '5 days';
  List xAxisLabels = [];
  bool isLoading = false;

  List<_ChartData> data = [];
  List<_ChartData1> data1 = [];

  //For Pronunciation Graph
  List<_ChartData> PronunciationData = [];
  List<_ChartData1> PronunciationData1 = [];

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  double? calculateMax(List<_ChartData> datas) {
    if (datas.isEmpty) return null; // Default max if the list is empty or less than 30

    double maxY = datas.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    double maxY1 = datas.map((e) => e.y1).reduce((a, b) => a > b ? a : b);
    double maxValue = maxY > maxY1 ? maxY : maxY1;

    // Ensure max value is at least 30
    return maxValue < 30 ? 30 : maxValue;
  }

  double? calculateMin(List<_ChartData> datas) {
    if (datas.isEmpty) return null;
    double maxY = datas.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    double maxY1 = datas.map((e) => e.y1).reduce((a, b) => a > b ? a : b);
    if (maxY >= maxY1) {
      return datas.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    } else {
      return datas.map((e) => e.y1).reduce((a, b) => a < b ? a : b);
    }
  }

  List<String> getXAxisLabels() {
    if (selectedTimePeriod == '5 Days') {
      print("5 daysss tappedddd");
      for (int i = 1; i <= 5; i++) {
        xAxisLabels.add("Day ${i}");
      }
      print("xAxisLabelssss:$xAxisLabels");
      //return ['Day 1', 'Day 2', 'Day 3', 'Day 4', 'Day 5'];
    } else if (selectedTimePeriod == '4 Weeks') {
      print("4 weeksss tappedddd");
      for (int i = 1; i <= 4; i++) {
        xAxisLabels.add("Week $i");
      }
      print("xAxisLabelssss:$xAxisLabels");
      //return ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
    } else if (selectedTimePeriod == '3 Months') {
      print("3 monthss tappeddd");
      for (int i = 1; i <= 3; i++) {
        xAxisLabels.add("Month $i");
      }
      print("xAxisLabelssss:$xAxisLabels");
      // return ['Month 1', 'Month 2', 'Month 3'];
    }
    return [];
  }

  //final List<DataItem> _myData = [];

  graphForSentenceAndCallFlow({required type}) async {
    isLoading = true;
    print("graph for sentence and call flow");
    String userId = await SharedPref.getSavedString('userId');
    print("userIddd:$userId");
    print("type:$type");
    String url = baseUrl + graphApi;
    print("url : $url");
    try {
      print("responseeeeeeee");
      var response = await http.post(Uri.parse(url), body: {
        "userid": userId,
        "type": type,
      });
      print("response of graph sentence and call flow report : ${response.body}");
      if (response.statusCode == 200 && type == "5 days") {
        setState(() {});
        print("5 days response");
        _daysResponse = DaysModel.fromJson(json.decode(response.body));
        data.clear();
        data1.clear();
        for (int i = 0; i < _daysResponse.data!.length; i++) {
          log("${_daysResponse.data![i].totalpracticeCount}");
          data.add(_ChartData(
              x: _daysResponse.data![i].date!, y: _daysResponse.data![i].totallisteningcount ?? 0.0, y1: _daysResponse.data![i].totalpracticeCount ?? 0.0));
          data1.add(_ChartData1(x: _daysResponse.data![i].date!, y: _daysResponse.data![i].averagescore ?? 0.0));
          print("average score for 5 days responseaaaaaaaaaaa:${_pronunciationDaysResponse.data![i].averageSuccessRate!.round()}");
          /* _myData.add(DataItem(
            x: DateFormat("yyyy-MM-dd").parse(_daysResponse.data![i].date!).millisecondsSinceEpoch,
            y1: _daysResponse.data![i].totallisteningcount ?? 0.0,
            y2: _daysResponse.data![i].totalpracticeCount ?? 0.0,
            y3: _daysResponse.data![i].averagescore ?? 0.0,
          ));*/
        }
        print("data1 List:${data1}");
      } else if (response.statusCode == 200 && type == "4 weeks") {
        setState(() {});
        print("4 weeks response");
        _weeksResponse = WeeksModel.fromJson(json.decode(response.body));
        data.clear();
        data1.clear();
        for (int i = 0; i < _weeksResponse.data!.length; i++) {
          data.add(_ChartData(
              x: _weeksResponse.data![i].weekStart!,
              y: _weeksResponse.data![i].totallisteningcount ?? 0.0,
              y1: _weeksResponse.data![i].totalpracticecount ?? 0.0));
          data1.add(_ChartData1(
            x: _weeksResponse.data![i].weekStart!,
            y: _weeksResponse.data![i].averageScore ?? 0.0,
          ));
          print("average score for 5 days response:${_weeksResponse.data![i].averageScore}");
          print("data1 List:${data1}");
          /*   _myData.add(DataItem(
            x: DateFormat("yyyy-MM-dd").parse(_weeksResponse.data![i].weekStart!).millisecondsSinceEpoch,
            y1: _weeksResponse.data![i].totallisteningcount ?? 0.0,
            y2: _weeksResponse.data![i].totalpracticecount ?? 0.0,
            y3: _weeksResponse.data![i].averageScore ?? 0.0,
          ));*/
        }
        print("sifigri:${_weeksResponse.data![0].weekStart}");
      } else if (response.statusCode == 200 && type == "3 months") {
        setState(() {});
        print("3 months response");
        _monthResponse = MonthsModel.fromJson(json.decode(response.body));
        data.clear();
        data1.clear();
        for (int i = 0; i < _monthResponse.data!.length; i++) {
          data.add(_ChartData(
            x: _monthResponse.data![i].monthStart!,
            y: _monthResponse.data![i].totallisteningcount ?? 0.0,
            y1: _monthResponse.data![i].totalpracticecount ?? 0.0,
          ));
          data1.add(_ChartData1(x: _monthResponse.data![i].monthStart!, y: _monthResponse.data![i].averageScore ?? 0.0));
          /*  _myData.add(DataItem(
              x: DateFormat("yyyy-MM-dd").parse(_monthResponse.data![i].monthStart!).millisecondsSinceEpoch,
              y1: _monthResponse.data![i].totallisteningcount ?? 0.0,
              y2: _monthResponse.data![i].totalpracticecount ?? 0.0,
              y3: _monthResponse.data![i].averageScore ?? 0.0));*/
        }
        print("sifigri:${_monthResponse.data![0].averageScore}");
      } else {
        print("errorr");
      }
    } catch (e) {
      print("error login : $e");
    }
    // await Future.delayed(Duration(seconds: 3));
    setState(() {});
    isLoading = false;
  }

  graphForPronunciationAndSounds({required type}) async {
    isLoading = true;
    print("graph for pronunciation and soundsss");
    String userId = await SharedPref.getSavedString('userId');
    print("userIddd:$userId");
    print("type:$type");
    String url = baseUrl + graphPronunciationAndSoundApi;
    print("url : $url");

    print("responseeeeeeee");
    var response = await http.post(Uri.parse(url), body: {
      "userid": userId,
      "type": type,
    });
    print("response of graph pronunciation and soundsss : ${response.body}");
    if (response.statusCode == 200 && type == "5 days") {
      setState(() {});
      print("5 days response");
      _pronunciationDaysResponse = PronunciationDaysModel.fromJson(json.decode(response.body));
      PronunciationData.clear();
      PronunciationData1.clear();
      for (int i = 0; i < _pronunciationDaysResponse.data!.length; i++) {
        PronunciationData.add(_ChartData(
            x: _pronunciationDaysResponse.data![i].date!,
            y: _pronunciationDaysResponse.data![i].totallisteningcount ?? 0.0,
            y1: _pronunciationDaysResponse.data![i].totalpracticecount ?? 0.0));
        PronunciationData1.add(_ChartData1(x: _pronunciationDaysResponse.data![i].date!, y: _pronunciationDaysResponse.data![i].averageSuccessRate ?? 0.0));
        print("average score for 5 days response:${_pronunciationDaysResponse.data![i].totalpracticecount}");
        /* _myData.add(DataItem(
            x: DateFormat("yyyy-MM-dd").parse(_daysResponse.data![i].date!).millisecondsSinceEpoch,
            y1: _daysResponse.data![i].totallisteningcount ?? 0.0,
            y2: _daysResponse.data![i].totalpracticeCount ?? 0.0,
            y3: _daysResponse.data![i].averagescore ?? 0.0,
          ));*/
      }
      print("dPronunciationData1 List:${data1}");
    } else if (response.statusCode == 200 && type == "4 weeks") {
      setState(() {});
      print("4 weeks response");
      _pronunciationWeeksResponse = PronunciationWeeksModel.fromJson(json.decode(response.body));
      PronunciationData.clear();
      PronunciationData1.clear();
      for (int i = 0; i < _pronunciationWeeksResponse.data!.length; i++) {
        PronunciationData.add(_ChartData(
            x: _pronunciationWeeksResponse.data![i].weekStart!,
            y: _pronunciationWeeksResponse.data![i].totallisteningcount ?? 0.0,
            y1: _pronunciationWeeksResponse.data![i].totalpracticecount ?? 0.0));
        PronunciationData1.add(_ChartData1(
          x: _pronunciationWeeksResponse.data![i].weekStart!,
          y: _pronunciationWeeksResponse.data![i].averageSuccessRate ?? 0.0,
        ));
        print("average score for weeks days response:${_pronunciationWeeksResponse.data![i].averageSuccessRate}");
        print("PronunciationData1 List:${PronunciationData1}");
        /*   _myData.add(DataItem(
            x: DateFormat("yyyy-MM-dd").parse(_weeksResponse.data![i].weekStart!).millisecondsSinceEpoch,
            y1: _weeksResponse.data![i].totallisteningcount ?? 0.0,
            y2: _weeksResponse.data![i].totalpracticecount ?? 0.0,
            y3: _weeksResponse.data![i].averageScore ?? 0.0,
          ));*/
      }
      print("sifigri:${_pronunciationWeeksResponse.data![0].weekStart}");
    } else if (response.statusCode == 200 && type == "3 months") {
      setState(() {});
      print("3 months response");
      _pronunciationMonthsResponse = PronunciationMonthsModel.fromJson(json.decode(response.body));
      PronunciationData.clear();
      PronunciationData1.clear();
      for (int i = 0; i < _pronunciationMonthsResponse.data!.length; i++) {
        PronunciationData.add(_ChartData(
          x: _pronunciationMonthsResponse.data![i].monthStart!,
          y: _pronunciationMonthsResponse.data![i].totallisteningcount ?? 0.0,
          y1: _pronunciationMonthsResponse.data![i].totalpracticecount ?? 0.0,
        ));
        PronunciationData1.add(
            _ChartData1(x: _pronunciationMonthsResponse.data![i].monthStart!, y: _pronunciationMonthsResponse.data![i].averageSuccessRate ?? 0.0));
        /*  _myData.add(DataItem(
              x: DateFormat("yyyy-MM-dd").parse(_monthResponse.data![i].monthStart!).millisecondsSinceEpoch,
              y1: _monthResponse.data![i].totallisteningcount ?? 0.0,
              y2: _monthResponse.data![i].totalpracticecount ?? 0.0,
              y3: _monthResponse.data![i].averageScore ?? 0.0));*/
      }
      print("sifigri:${_pronunciationMonthsResponse.data![0].averageSuccessRate}");
    } else {
      print("errorr");
    }
    // await Future.delayed(Duration(seconds: 3));
    setState(() {});
    isLoading = false;
  }

  double? calculateInterval(double min, double max, int steps) {
    return (max - min) / steps;
  }

  Widget build(BuildContext context) {
    final controller = Provider.of<AuthState>(context, listen: false);
    kText = MediaQuery.of(context).textScaler;
    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        context.read<AuthState>().changeIndex(0);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
      },
      child: BackgroundWidget(
        appBar: CommonAppBar(
          appbarIcon: AllAssets.ptIcon,
          title: 'Performance Tracking',
          // height: displayHeight(context) / 12.6875,
        ),
        body: Padding(
          padding: EdgeInsets.only(top: isSplitScreen ? getFullWidgetHeight(height: 15) : getWidgetHeight(height: 15)),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Container(
                    decoration: BoxDecoration(color: Color(0XFF35405E), borderRadius: BorderRadius.circular(5)),
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 2,
                      controller: _pageController,
                      onPageChanged: (page) {
                        activePage = page;
                        print("activePage:$activePage");
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                  child: index == 0
                                      ? Text(
                                          'Sentence Practice',
                                          style: TextStyle(color: Colors.white),
                                        )
                                      : Text(
                                          'Pronunciation Lab Progress',
                                          style: TextStyle(color: Colors.white),
                                        )),
                              if (isLoading)
                                Expanded(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              else
                                index == 0
                                    ? Expanded(
                                        child: SizedBox(
                                          height: 300,
                                          child: Stack(
                                            children: [
                                              Transform(
                                                transform: Matrix4.identity()..translate(-16.0, 0.0, 0.0),
                                                child: SfCartesianChart(
                                                  plotAreaBorderWidth: 0.0,
                                                  primaryXAxis: CategoryAxis(
                                                      majorGridLines: MajorGridLines(width: 0, color: Colors.grey),
                                                      majorTickLines: MajorTickLines(width: 0, color: Colors.grey),
                                                      axisLine: AxisLine(width: 0),
                                                      labelStyle: TextStyle(color: Colors.white)),
                                                  primaryYAxis: NumericAxis(
                                                    minimum: calculateMin(data) ?? 0, // Dynamic minimum
                                                    maximum: calculateMax(data) ?? 30, // Dynamic maximum
                                                    interval: calculateInterval(calculateMin(data) ?? 0.00, calculateMax(data) ?? 30.00, 10) ?? 3,
                                                    majorTickLines: MajorTickLines(width: 0, color: Colors.grey),
                                                    axisLine: AxisLine(width: 0),
                                                    labelStyle: TextStyle(color: Colors.white),
                                                    //majorGridLines: MajorGridLines(width: 0),
                                                  ),
                                                  series: <CartesianSeries<_ChartData, String>>[
                                                    ColumnSeries<_ChartData, String>(
                                                      dataSource: data,
                                                      xValueMapper: (_ChartData data, _) => data.x,
                                                      yValueMapper: (_ChartData data, _) => data.y,
                                                      width: 0.4,
                                                      spacing: 0.2,
                                                      color: Color(0XFF6A61FC),
                                                      dataLabelSettings: DataLabelSettings(
                                                        isVisible: true,
                                                        labelAlignment: ChartDataLabelAlignment.top,
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                    ColumnSeries<_ChartData, String>(
                                                      dataSource: data,
                                                      xValueMapper: (_ChartData data, _) => data.x,
                                                      yValueMapper: (_ChartData data, _) => data.y1,
                                                      width: 0.4,
                                                      spacing: 0.2,
                                                      color: Color(0XFF3DC94E),
                                                      dataLabelSettings: DataLabelSettings(
                                                        // labelAlignment: ChartDataLabelAlignment.auto, // Automatically adjust alignment
                                                        // overflowMode: OverflowMode.shift,
                                                        isVisible: true,
                                                        labelAlignment: ChartDataLabelAlignment.top,
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Transform(
                                                transform: Matrix4.identity()..translate(20.0, 0.0, 0.0),
                                                child: SfCartesianChart(
                                                  plotAreaBorderWidth: 0.0,
                                                  primaryXAxis: CategoryAxis(
                                                    majorGridLines: MajorGridLines(width: 0, color: Colors.grey),
                                                    majorTickLines: MajorTickLines(width: 0, color: Colors.grey),
                                                    labelStyle: TextStyle(color: Colors.transparent),
                                                    axisLine: AxisLine(width: 0),
                                                  ),
                                                  primaryYAxis: NumericAxis(
                                                      minimum: 0,
                                                      maximum: 100,
                                                      interval: 10,
                                                      opposedPosition: true,
                                                      labelStyle: TextStyle(color: Colors.white),
                                                      majorGridLines: MajorGridLines(width: 0, color: Colors.grey),
                                                      majorTickLines: MajorTickLines(width: 0, color: Colors.grey),
                                                      axisLine: AxisLine(width: 0),
                                                      labelFormat: "{value}%",
                                                      numberFormat: NumberFormat.compact(),
                                                      rangePadding: ChartRangePadding.normal),
                                                  series: <CartesianSeries<_ChartData1, String>>[
                                                    LineSeries<_ChartData1, String>(
                                                      dataSource: data1,
                                                      xValueMapper: (_ChartData1 data, _) => data.x,
                                                      yValueMapper: (_ChartData1 data, _) => data.y,
                                                      color: Colors.white,
                                                      markerSettings: MarkerSettings(
                                                        isVisible: true,
                                                        shape: DataMarkerType.triangle,
                                                        width: 8,
                                                        height: 8,
                                                        borderColor: Colors.yellow,
                                                        borderWidth: 2,
                                                      ),
                                                      dataLabelSettings: DataLabelSettings(
                                                        isVisible: true,
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: kText.scale(10),
                                                        ),
                                                        labelAlignment: ChartDataLabelAlignment.top,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: SizedBox(
                                          height: 300,
                                          child: Stack(
                                            children: [
                                              Transform(
                                                transform: Matrix4.identity()..translate(-16.0, 0.0, 0.0),
                                                child: SfCartesianChart(
                                                  plotAreaBorderWidth: 0.0,
                                                  primaryXAxis: CategoryAxis(
                                                      majorGridLines: MajorGridLines(width: 0, color: Colors.grey),
                                                      majorTickLines: MajorTickLines(width: 0, color: Colors.grey),
                                                      axisLine: AxisLine(width: 0),
                                                      labelStyle: TextStyle(color: Colors.white)),
                                                  primaryYAxis: NumericAxis(
                                                    minimum: 0,
                                                    maximum: 30,
                                                    interval: 3,
                                                    majorTickLines: MajorTickLines(width: 0, color: Colors.grey),
                                                    axisLine: AxisLine(width: 0),
                                                    labelStyle: TextStyle(color: Colors.white),
                                                    //majorGridLines: MajorGridLines(width: 0),
                                                  ),
                                                  series: <CartesianSeries<_ChartData, String>>[
                                                    ColumnSeries<_ChartData, String>(
                                                      dataSource: PronunciationData,
                                                      xValueMapper: (_ChartData data, _) => data.x,
                                                      yValueMapper: (_ChartData data, _) => data.y,
                                                      width: 0.4,
                                                      spacing: 0.2,
                                                      color: Color(0XFF6A61FC),
                                                      dataLabelSettings: DataLabelSettings(
                                                        isVisible: true,
                                                        labelAlignment: ChartDataLabelAlignment.top,
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                    ColumnSeries<_ChartData, String>(
                                                      dataSource: PronunciationData,
                                                      xValueMapper: (_ChartData data, _) => data.x,
                                                      yValueMapper: (_ChartData data, _) => data.y1,
                                                      width: 0.4,
                                                      spacing: 0.2,
                                                      color: Color(0XFF3DC94E),
                                                      dataLabelSettings: DataLabelSettings(
                                                        isVisible: true,
                                                        labelAlignment: ChartDataLabelAlignment.top,
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Transform(
                                                transform: Matrix4.identity()..translate(20.0, 0.0, 0.0),
                                                child: SfCartesianChart(
                                                  plotAreaBorderWidth: 0.0,
                                                  primaryXAxis: CategoryAxis(
                                                    majorGridLines: MajorGridLines(width: 0, color: Colors.grey),
                                                    majorTickLines: MajorTickLines(width: 0, color: Colors.grey),
                                                    labelStyle: TextStyle(color: Colors.transparent),
                                                    axisLine: AxisLine(width: 0),
                                                  ),
                                                  primaryYAxis: NumericAxis(
                                                      minimum: 0,
                                                      maximum: 100,
                                                      interval: 10,
                                                      opposedPosition: true,
                                                      labelStyle: TextStyle(color: Colors.white),
                                                      majorGridLines: MajorGridLines(width: 0, color: Colors.grey),
                                                      majorTickLines: MajorTickLines(width: 0, color: Colors.grey),
                                                      axisLine: AxisLine(width: 0),
                                                      labelFormat: "{value}%",
                                                      numberFormat: NumberFormat.compact(),
                                                      rangePadding: ChartRangePadding.normal),
                                                  series: <CartesianSeries<_ChartData1, String>>[
                                                    LineSeries<_ChartData1, String>(
                                                      dataSource: PronunciationData1,
                                                      xValueMapper: (_ChartData1 data, _) => data.x,
                                                      yValueMapper: (_ChartData1 data, _) => data.y,
                                                      color: Colors.white,
                                                      markerSettings: MarkerSettings(
                                                        isVisible: true,
                                                        shape: DataMarkerType.triangle,
                                                        width: 8,
                                                        height: 8,
                                                        borderColor: Colors.yellow,
                                                        borderWidth: 2,
                                                      ),
                                                      dataLabelSettings: DataLabelSettings(
                                                        isVisible: true,
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: kText.scale(10),
                                                        ),
                                                        labelAlignment: ChartDataLabelAlignment.top,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              SizedBox(
                                height: isSplitScreen ? getFullWidgetHeight(height: 15) : getWidgetHeight(height: 15),
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: isSplitScreen ? getFullWidgetHeight(height: 7) : getWidgetHeight(height: 7),
                                        width: getWidgetWidth(width: 22),
                                        decoration: BoxDecoration(color: Color(0XFF6A61FC)),
                                      ),
                                      SizedBox(width: getWidgetWidth(width: 3)),
                                      Text(
                                        "Listening Attempts",
                                        style: TextStyle(color: Colors.white, fontSize: kText.scale(9)),
                                      ),
                                      SizedBox(
                                        width: getWidgetWidth(width: 8),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        height: isSplitScreen ? getFullWidgetHeight(height: 7) : getWidgetHeight(height: 7),
                                        width: getWidgetWidth(width: 22),
                                        decoration: BoxDecoration(color: Color(0XFF3DC94E)),
                                      ),
                                      SizedBox(width: getWidgetWidth(width: 3)),
                                      Text(
                                        "Practice Attempts",
                                        style: TextStyle(color: Colors.white, fontSize: kText.scale(9)),
                                      ),
                                      SizedBox(
                                        width: getWidgetWidth(width: 8),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/Line.png",
                                        height: isSplitScreen ? getFullWidgetHeight(height: 15) : getWidgetHeight(height: 15),
                                        width: getWidgetWidth(width: 35),
                                      ),
                                      SizedBox(width: getWidgetWidth(width: 3)),
                                      Text(
                                        "Speech Score",
                                        style: TextStyle(color: Colors.white, fontSize: kText.scale(9)),
                                      ),
                                      SizedBox(
                                        width: getWidgetWidth(width: 8),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: isSplitScreen ? getFullWidgetHeight(height: 15) : getWidgetHeight(height: 15),
                              ),
                              index == 0
                                  ? Row(
                                      children: [
                                        _buildTimePeriodButton("5 days", 0),
                                        SizedBox(width: 8),
                                        _buildTimePeriodButton("4 weeks", 0),
                                        SizedBox(width: 8),
                                        _buildTimePeriodButton("3 months", 0),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        _buildTimePeriodButton("5 days", 1),
                                        SizedBox(width: 8),
                                        _buildTimePeriodButton("4 weeks", 1),
                                        SizedBox(width: 8),
                                        _buildTimePeriodButton("3 months", 1),
                                      ],
                                    ),
                              SizedBox(height: isSplitScreen ? getFullWidgetHeight(height: 15) : getWidgetHeight(height: 15)),
                              Center(
                                child: SmoothPageIndicator(
                                  controller: _pageController,
                                  count: 2,
                                  effect: ScrollingDotsEffect(
                                    activeDotScale: 1.5,
                                    activeDotColor: const Color(0xff0C8CE9),
                                    dotColor: const Color(0xffD1F4FF),
                                    dotHeight: 6,
                                    dotWidth: 20,
                                    radius: 3,
                                    spacing: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              ListView.builder(
                  itemCount: controller.labReports.length - 1,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        NewSubMenuItem(
                          onTap: () async {
                            if (index == 0) {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setString('lastAccess', 'PronunciationReport');
                            } else if (index == 1) {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setString('lastAccess', 'SpeechReport');
                            } else if (index == 2) {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setString('lastAccess', 'CallFlowReport');
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => controller.labReports[index]['page']),
                            );
                          },
                          backgroundImage: AllAssets.back1,
                          menuText: controller.labReports[index]['title'],
                          image: controller.labReports[index]['icon'],
                          bgColor: controller.labReports[index]['bgColor'],
                        ),
                        Divider(
                          indent: 20,
                          endIndent: 20,
                          color: Color(0xFF34445F),
                        ),
                      ],
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodButton(String period, int index) {
    return InkWell(
      onTap: () {
        print("period: $period");
        print("indexxxValueee:$index");
        setState(() {
          index == 0 ? selectedTimePeriod = period : PronunciationSelectedTimePeriod = period;
          index == 0 ? graphForSentenceAndCallFlow(type: period) : graphForPronunciationAndSounds(type: period);
        });
      },
      child: index == 0
          ? Container(
              alignment: Alignment.center,
              height: isSplitScreen ? getFullWidgetHeight(height: 40) : getWidgetHeight(height: 40),
              width: getWidgetWidth(width: 103),
              decoration: BoxDecoration(
                  color: selectedTimePeriod == period ? Colors.white : Color(0XFF35405E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white)),
              child: Text(
                period,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selectedTimePeriod == period ? Colors.black : Colors.white,
                ),
              ),
            )
          : Container(
              alignment: Alignment.center,
              height: isSplitScreen ? getFullWidgetHeight(height: 40) : getWidgetHeight(height: 40),
              width: getWidgetWidth(width: 103),
              decoration: BoxDecoration(
                  color: PronunciationSelectedTimePeriod == period ? Colors.white : Color(0XFF35405E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white)),
              child: Text(
                period,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PronunciationSelectedTimePeriod == period ? Colors.black : Colors.white,
                ),
              ),
            ),
    );
  }
}

class _ChartData {
  _ChartData({required this.x, required this.y, required this.y1});
  final String x;
  final double y;
  final double y1;
}

class _ChartData1 {
  _ChartData1({required this.x, required this.y});
  final String x;
  final double y;
}
