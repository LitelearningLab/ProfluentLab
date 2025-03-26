import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:litelearninglab/models/ProLab.dart';
import 'package:litelearninglab/models/SpeechLab.dart';
import 'package:litelearninglab/models/UserM.dart';
import 'package:litelearninglab/models/Word.dart';

import '../models/InteracticeSimulationMain.dart';
import '../models/ProcessLearningMain.dart';
import '../models/ProfluentEnglish.dart';
import '../models/SoftSkills.dart';
import 'FirestoreService.dart';

class FirebaseHelper {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FirebaseHelper _instance = new FirebaseHelper.internal();

  factory FirebaseHelper() => _instance;
  final _userNode = FirestoreService<UserM>('UserNode');
  final _proLabReports = FirestoreService<ProLab>('proLabReports');
  final _errorsFromSpeechReports = FirestoreService<ProLab>('errorsFromSpeechReports');
  final _sentLabCollection = FirestoreService<SpeechLab>('sentLabReports');
  final _callFlowCollection = FirestoreService<SpeechLab>('callFlowReports');
  final _processLearningCollection = FirestoreService<ProcessLearningMain>('processLearning');
  final _interacticeSimulationMainCollection = FirestoreService<InteracticeSimulationMain>('interactiveSimulations');
  final _softSkillsCollection = FirestoreService<SoftSkills>('softSkills');
  final _prolfuentCollection = FirestoreService<ProfluentEnglish>('profluentEnglish');

  FirebaseHelper.internal();

  Future<List<ProLab>> getErrorsReport(String userID) async {
    final conditions = [
      ['userId', '==', userID],
    ];
    return await _errorsFromSpeechReports.getWhere(conditions);
  }

  Future<List<ProLab>> getProLabReports(String userID) async {
    final conditions = [
      ['userId', '==', userID],
    ];

    return await _proLabReports.getWhere(conditions, orderBy: "date", descending: true);
  }

  Future<List<SpeechLab>> getSpeechLabReports(String userID) async {
    final conditions = [
      ['userId', '==', userID],
    ];
    return await _sentLabCollection.getWhere(conditions);
  }

  Future<List<SpeechLab>> getCallFlowReports(String userID) async {
    final conditions = [
      ['userId', '==', userID],
    ];
    return await _callFlowCollection.getWhere(conditions);
  }

  Future<List<ProLab>> getProLabDateReports(String userID, String word) async {
    final conditions = [
      ['userId', '==', userID],
      ['word', '==', word],
    ];
    return await _proLabReports.getWhere(conditions);
  }

  Future<List<ProcessLearningMain>> getProcessLearning() async {
    return await _processLearningCollection.getAllDocuments(orderBy: 'order', descending: true);
  }

  Future<List<InteracticeSimulationMain>> getInteractiveSimuations() async {
    return await _interacticeSimulationMainCollection.getAllDocuments(orderBy: 'order', descending: true);
  }

  Future<List<SoftSkills>> getSoftSkills() async {
    return await _softSkillsCollection.getAllDocuments(orderBy: 'order', descending: true);
  }

  Future<List<ProfluentEnglish>> getProfluentEnglish() async {
    return await _prolfuentCollection.getAllDocuments(orderBy: 'order', descending: true);
  }

  //get manually stored words

  Future<List<Word>> getWordSamples() async {
    final documentReference = FirebaseFirestore.instance.collection('wordSamples');
    final snapshot = await documentReference.get();
    return snapshot.docs.map((doc) => Word.fromMap(doc.data())).toList();
  }

//   List<Word> getWordSamplesSync() {
//   List<Word> words = [];
//   getWordSamples().then((value) {
//     words = value;
//   }).catchError((error) {
//     print("Error fetching word samples: $error");
//   });

//   return words;
// }

//end

  Future<void> saveSentenceListReport(
      {required String company,
      String? name,
      required String userID,
      required String sentence,
      String? team,
      String? userprofile,
      String? city,
      required String date,
      List? focusWords,
      List? correctWords,
      double score = 0,
      bool isPractice = true,
      bool isCorrect = false,
      String? title,
      String? load,
      String? timeCal,
      String? main}) async {
    print("jhihihihi : $title");
    print("jhihihihi : $main");
    print("jhihihihi : $load");
    date = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    final conditions = [
      ['userId', '==', userID],
      ['sentence', '==', sentence],
      ['dateTime', '==', date],
    ];
    var existingDoc = await _sentLabCollection.getWhere(conditions);

    if (existingDoc.isNotEmpty) {
      print("sentebce if part 1111111");
      var docId = existingDoc[0].id;

      existingDoc[0].time = (existingDoc[0].time ?? 0) + 1;
      if (isCorrect) {
        existingDoc[0].correct = (existingDoc[0].correct ?? 0) + 1;
      }
      if (isPractice) {
        if (existingDoc[0].pracatt == null) {
          existingDoc[0].pracatt = 1;
        } else {
          existingDoc[0].pracatt = (existingDoc[0].pracatt ?? 0) + 1;
        }
      } else {
        if (existingDoc[0].listatt == null) {
          existingDoc[0].listatt = 1;
        } else {
          existingDoc[0].listatt = (existingDoc[0].listatt ?? 0) + 1;
        }
      }
      if (existingDoc[0].score == null) {
        existingDoc[0].score = score;
      } else {
        existingDoc[0].score = (existingDoc[0].score ?? 0) + score;
      }
      existingDoc[0].lastScore = score;
      existingDoc[0].lastAttempt = DateTime.now().toString();
      print("existingDoc");
      if (focusWords != null && focusWords.isNotEmpty) {
        if (existingDoc[0].focusWord == null) {
          focusWords.add(score.toStringAsFixed(2));
          Map<String, List<dynamic>> focusWordMap = {
            '${DateFormat('HH:mm:ss').format(DateTime.now())}': focusWords,
          };
          print(focusWordMap);
          existingDoc[0].focusWord = focusWordMap;
        } else {
          focusWords.add(score.toStringAsFixed(2));
          existingDoc[0].focusWord?.putIfAbsent(DateFormat('HH:mm:ss').format(DateTime.now()), () => focusWords);
        }
      }

      print(focusWords);
      print(existingDoc.first.toMap());
      await _sentLabCollection.updateDocument(existingDoc[0], docId!);
    } else {
      print("sentebce else part 1");
      var data = SpeechLab.fromMap({
        'userId': userID,
        'sentence': sentence,
        'date': date,
        'time': 1,
        'correct': isCorrect ? 1 : 0,
        'listatt': !isPractice ? 1 : 0,
        'pracatt': isPractice ? 1 : 0,
        'score': score,
        'lastScore': score,
        "lastAttempt": DateTime.now().toString(),
        "dateTime": date,
        "title": title,
        "load": load,
        "main": main,
        "timeCal": DateTime.now().millisecondsSinceEpoch,
      });
      if (focusWords != null && focusWords.isNotEmpty) {
        data.focusWord = {};
        focusWords.add(score.toStringAsFixed(2));
        data.focusWord?.putIfAbsent(DateFormat('HH:mm:ss').format(DateTime.now()), () => focusWords);
      }

      await _sentLabCollection.addDocument(data);
    }
    for (String word in (focusWords ?? [])) {
      await saveErrorsFromSpeechReport(
          company: company,
          city: city ?? "",
          date: date,
          team: team ?? "",
          isCorrect: false,
          isPractice: true,
          word: word,
          time: 1,
          userID: userID,
          userprofile: userprofile ?? "");
    }
    for (String word in (correctWords ?? [])) {
      await saveErrorsFromSpeechReport(
          company: company,
          city: city ?? "",
          date: date,
          team: team ?? "",
          isCorrect: true,
          isPractice: true,
          word: word,
          time: 1,
          userID: userID,
          userprofile: userprofile ?? "");
    }
  }

  Future<void> saveCallFlowReport(
      {required String company,
      String? name,
      required String userID,
      required String sentence,
      String? team,
      String? userprofile,
      String? city,
      required String date,
      List? focusWords,
      List? correctWords,
      double score = 0,
      bool isPractice = true,
      bool isCorrect = false,
      String? title,
      String? load,
      String? timeCal,
      String? main}) async {
    print("checkkkk>>>>>>>>>>>>>>>>>>>>>");
    date = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    final conditions = [
      ['userId', '==', userID],
      ['sentence', '==', sentence],
      ['dateTime', '==', date],
    ];
    var existingDoc = await _callFlowCollection.getWhere(conditions);

    if (existingDoc.isNotEmpty) {
      print("check1111111111");
      var docId = existingDoc[0].id;

      existingDoc[0].time = (existingDoc[0].time ?? 0) + 1;
      if (isCorrect) {
        existingDoc[0].correct = (existingDoc[0].correct ?? 0) + 1;
      }
      if (isPractice) {
        if (existingDoc[0].pracatt == null) {
          existingDoc[0].pracatt = 1;
        } else {
          existingDoc[0].pracatt = (existingDoc[0].pracatt ?? 0) + 1;
        }
      } else {
        if (existingDoc[0].listatt == null) {
          existingDoc[0].listatt = 1;
        } else {
          existingDoc[0].listatt = (existingDoc[0].listatt ?? 0) + 1;
        }
      }
      if (existingDoc[0].score == null) {
        existingDoc[0].score = score;
      } else {
        existingDoc[0].score = (existingDoc[0].score ?? 0) + score;
      }
      existingDoc[0].lastScore = score;
      existingDoc[0].lastAttempt = DateTime.now().toString();
      print("existingDoc");
      if (focusWords != null && focusWords.isNotEmpty) {
        print("check3333333");
        if (existingDoc[0].focusWord == null) {
          print("checkkkkkk44");
          focusWords.add(score.toStringAsFixed(2));
          Map<String, dynamic> focusWordMap = {
            '${DateFormat('HH:mm:ss').format(DateTime.now())}': focusWords,
          };
          print(focusWordMap);
          existingDoc[0].focusWord = focusWordMap;
        } else {
          print("checkkkkk55555");
          //existingDoc[0].focusWord?.putIfAbsent('focusedScore', () => score.toStringAsFixed(2));
          focusWords.add(score.toStringAsFixed(2));
          existingDoc[0].focusWord?.putIfAbsent(DateFormat('HH:mm:ss').format(DateTime.now()), () => focusWords);
        }
      }

      print(focusWords);
      print(existingDoc.first.toMap());
      await _callFlowCollection.updateDocument(existingDoc[0], docId!);
    } else {
      print("check22222222222222");
      var data = SpeechLab.fromMap({
        'userId': userID,
        'sentence': sentence,
        'date': date,
        'time': 1,
        'correct': isCorrect ? 1 : 0,
        'listatt': !isPractice ? 1 : 0,
        'pracatt': isPractice ? 1 : 0,
        'score': score,
        'lastScore': score,
        "lastAttempt": DateTime.now().toString(),
        "dateTime": date,
        "title": title,
        "load": load,
        "main": main,
        "timeCal": DateTime.now().millisecondsSinceEpoch,
      });
      if (focusWords != null && focusWords.isNotEmpty) {
        print("djfhehriehiehifrewweewhriwe");
        data.focusWord = {};
        focusWords.add(score.toStringAsFixed(2));
        data.focusWord?.putIfAbsent(DateFormat('HH:mm:ss').format(DateTime.now()), () => focusWords);
      }

      await _callFlowCollection.addDocument(data);
    }
    for (String word in (focusWords ?? [])) {
      await saveErrorsFromSpeechReport(
          company: company,
          city: city ?? "",
          date: date,
          team: team ?? "",
          isCorrect: false,
          isPractice: true,
          word: word,
          time: 1,
          userID: userID,
          userprofile: userprofile ?? "");
    }
    for (String word in (correctWords ?? [])) {
      await saveErrorsFromSpeechReport(
          company: company,
          city: city ?? "",
          date: date,
          team: team ?? "",
          isCorrect: true,
          isPractice: true,
          word: word,
          time: 1,
          userID: userID,
          userprofile: userprofile ?? "");
    }
  }

  Future<void> saveWordListReport(
      {required String company,
      String? name,
      required int time,
      required String userID,
      required String word,
      String? team,
      String? userprofile,
      String? city,
      String? load,
      String? title,
      String? timeCal,
      required String date,
      bool isPractice = true,
      bool isCorrect = false}) async {
    print("checkkingggg>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    date = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    final conditions = [
      ['userId', '==', userID],
      ['word', '==', word],
      ['date', '==', date],
    ];
    var existingDoc = await _proLabReports.getWhere(conditions);

    if (existingDoc.isNotEmpty) {
      var docId = existingDoc[0].id;

      existingDoc[0].listatt = (existingDoc[0].listatt ?? 0) + 1;
      existingDoc[0].time = (existingDoc[0].time ?? 0) + 1;
      if (isCorrect) {
        existingDoc[0].correct = (existingDoc[0].correct ?? 0) + 1;
      }
      if (isPractice) {
        if (existingDoc[0].pracatt == null) {
          print("djfdjfdif");
          existingDoc[0].pracatt = 1;
        } else {
          print("else part calleddd");
          existingDoc[0].pracatt = (existingDoc[0].pracatt ?? 0) + 1;
          existingDoc[0].timeCal = DateTime.now().millisecondsSinceEpoch;
        }
      }

      await _proLabReports.updateDocument(existingDoc[0], docId!);
    } else {
      print("elseee partt calleddddddd");
      var data = ProLab.fromMap({
        'userId': userID,
        'word': word,
        'date': date,
        'time': 1,
        'correct': isCorrect ? 1 : 0,
        'listatt': 1,
        'load': load,
        'title': title,
        'company': company,
        'timeCal': DateTime.now().millisecondsSinceEpoch,
      });
      print("dfdjnfijjij");
      if (isPractice) {
        data.pracatt = 1;
        //existingDoc[0].timeCal = DateTime.now().millisecondsSinceEpoch;
      }
      await _proLabReports.addDocument(data);
    }
  }

  Future<void> saveErrorsFromSpeechReport(
      {required String company,
      String? name,
      required int time,
      required String userID,
      required String word,
      String? team,
      String? userprofile,
      String? city,
      String? load,
      String? title,
      String? date,
      bool isPractice = true,
      bool isCorrect = false}) async {
    date = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    final conditions = [
      ['userId', '==', userID],
      ['word', '==', word],
      ['date', '==', date],
    ];
    var existingDoc = await _errorsFromSpeechReports.getWhere(conditions);

    if (existingDoc.isNotEmpty) {
      var docId = existingDoc[0].id;

      existingDoc[0].listatt = (existingDoc[0].listatt ?? 0) + 1;
      existingDoc[0].time = (existingDoc[0].time ?? 0) + 1;
      if (isCorrect) {
        existingDoc[0].correct = (existingDoc[0].correct ?? 0) + 1;
      }
      if (isPractice) {
        print("checkkeddddd");
        if (existingDoc[0].pracatt == null) {
          existingDoc[0].pracatt = 1;
        } else
          existingDoc[0].pracatt = (existingDoc[0].pracatt ?? 0) + 1;
      }

      await _errorsFromSpeechReports.updateDocument(existingDoc[0], docId!);
    } else {
      print("checkingggg");
      var data = ProLab.fromMap({
        'userId': userID,
        'word': word,
        'date': date,
        'time': 1,
        'correct': isCorrect ? 1 : 0,
        'listatt': 1,
        'load': load,
        'title': title,
      });
      if (isPractice) {
        data.pracatt = 1;
      }
      await _errorsFromSpeechReports.addDocument(data);
    }
  }

  Future<UserM?> getUser(String userID) async {
    print("mobile number jysyissysyfyis");
    print(userID);
    final conditions = [
      ['mobile', '==', userID],
    ];
    try {
      final data = await _userNode.getWhere(conditions);
      print("Data received: $data");
      print("data printing>>>");
      print(data.toString());
      if (data.length > 0) {
        return data.first;
      }
    } catch (e) {
      print("Error fetching data: $e");
    }

    return null;
  }

  Future<void> setUserImei(String imei, String model, String userID) async {
    String? fcmToken = await _firebaseMessaging.getToken();
    print("fcmtoken : $fcmToken");
    await _userNode.updateDocument(UserM(imei: imei, model: model, fcmKey: fcmToken), userID);
  }
}
