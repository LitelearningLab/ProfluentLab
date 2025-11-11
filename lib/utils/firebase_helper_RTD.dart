import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:litelearninglab/database/SentDatabaseProvider.dart';
import 'package:litelearninglab/database/SentencesDatabaseRepository.dart';
import 'package:litelearninglab/database/WordsDatabaseRepository.dart';
import 'package:litelearninglab/database/databaseProvider.dart';
import 'package:litelearninglab/models/Sentence.dart';
import 'package:litelearninglab/models/SentenceCat.dart';
import 'package:litelearninglab/models/Word.dart';
import 'package:litelearninglab/utils/shared_pref.dart';

class FirebaseHelperRTD {
  static final FirebaseHelperRTD _instance = new FirebaseHelperRTD.internal();

  factory FirebaseHelperRTD() => _instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Sentence> _sentences = [];

  FirebaseHelperRTD.internal();

  Future<List<Word>> searchWord(String searchTerm) async {
    List<Word> words = [];
    words.clear();
    print("searchTerm : $searchTerm");
    print("words : $words");
    print("words length : ${words.length}");
    print("fetching words>>>>>>>>>>>>>>>>>>");
    List<Word> daysdates = await getWords("daysdates");
    // words.addAll(daysdates.where((element) => element.text?.toLowerCase() == searchTerm.toLowerCase()).toList());
    words.addAll(daysdates
        .where((element) =>
            element.text!.toLowerCase().startsWith(searchTerm.toLowerCase()))
        .toList());
    print("words : $words");
    print("words length : ${words.length}");
    print("daydates func ended>>>>>>>>>>>>>>>>>>");

    // if (words.length > 0) return words;

    List<Word> LattersandNATO = await getWords("Latters and NATO");
    words.addAll(LattersandNATO.where((element) =>
            element.text!.toLowerCase().startsWith(searchTerm.toLowerCase()))
        .toList());
    print("words : $words");
    print("words length : ${words.length}");
    print("Latters and NATO func ended>>>>>>>>>>>>>>>>>>");

    List<Word> StatesandCities = await getWords("States and Cities");
    words.addAll(StatesandCities.where((element) =>
            element.text!.toLowerCase().startsWith(searchTerm.toLowerCase()))
        .toList());
    print("words : $words");
    print("words length : ${words.length}");
    print("States and Cities func ended>>>>>>>>>>>>>>>>>>");
    // words.addAll(StatesandCities.where((element) =>
    //     element.text?.toLowerCase() == searchTerm.toLowerCase()).toList());
    // if (words.length > 0) return words;

    List<Word> CommonWords = await getWords("CommonWords");
    words.addAll(CommonWords.where((element) =>
            element.text!.toLowerCase().startsWith(searchTerm.toLowerCase()))
        .toList());
    print("words : $words");
    print("words length : ${words.length}");
    print("CommonWords func ended>>>>>>>>>>>>>>>>>>");
    // words.addAll(CommonWords.where((element) =>
    //     element.text?.toLowerCase() == searchTerm.toLowerCase()).toList());
    // if (words.length > 0) return words;

    List<Word> USHealthcare = await getWords("US Healthcare");
    words.addAll(USHealthcare.where((element) =>
            element.text!.toLowerCase().startsWith(searchTerm.toLowerCase()))
        .toList());
    print("words : $words");
    print("words length : ${words.length}");
    print("US Healthcare func ended>>>>>>>>>>>>>>>>>>");
    // words.addAll(USHealthcare.where((element) =>
    //     element.text?.toLowerCase() == searchTerm.toLowerCase()).toList());
    // if (words.length > 0) return words;

    List<Word> TravelTourism = await getWords("Travel Tourism");
    words.addAll(TravelTourism.where((element) =>
            element.text!.toLowerCase().startsWith(searchTerm.toLowerCase()))
        .toList());
    print("words : $words");
    print("words length : ${words.length}");
    print("Travel Tourism func ended>>>>>>>>>>>>>>>>>>");
    // words.addAll(TravelTourism.where((element) =>
    //     element.text?.toLowerCase() == searchTerm.toLowerCase()).toList());
    // if (words.length > 0) return words;

    List<Word> InformationTechnology = await getWords("Information Technology");
    words.addAll(InformationTechnology.where((element) =>
            element.text!.toLowerCase().startsWith(searchTerm.toLowerCase()))
        .toList());
    print("words : $words");
    print("words length : ${words.length}");
    print("Information Technology func ended>>>>>>>>>>>>>>>>>>");
    // words.addAll(InformationTechnology.where((element) =>
    //     element.text?.toLowerCase() == searchTerm.toLowerCase()).toList());
    // if (words.length > 0) return words;

    List<Word> BusinessWords = await getWords("Business Words");
    words.addAll(BusinessWords.where((element) =>
            element.text!.toLowerCase().startsWith(searchTerm.toLowerCase()))
        .toList());
    print("words : $words");
    print("words length : ${words.length}");
    print("Business Words func ended>>>>>>>>>>>>>>>>>>");
    // words.addAll(BusinessWords.where((element) =>
    //     element.text?.toLowerCase() == searchTerm.toLowerCase()).toList());
    // if (words.length > 0) return words;

    List<Word> ProcessWords = await getWords("ProcessWords");
    words.addAll(ProcessWords.where((element) =>
            element.text!.toLowerCase().startsWith(searchTerm.toLowerCase()))
        .toList());
    print("words : $words");
    print("words length : ${words.length}");
    print("ProcessWords func ended>>>>>>>>>>>>>>>>>>");
    // words.addAll(ProcessWords.where((element) =>
    //     element.text?.toLowerCase() == searchTerm.toLowerCase()).toList());
    if (words.length > 0) return words;

    return words;
  }

  Future<List<Word>> lettersAndNatp(String searchTerm) async {
    List<Word> lettersAndNatp = [];
    List<Word> LattersandNATO = await getWords("Latters and NATO");
    log("${LattersandNATO.length}");
    for (Word i in LattersandNATO) {
      log("${i.text}");
    }
    log("lettersAndnatp only length has been printed");
    lettersAndNatp.addAll(LattersandNATO.where((element) =>
            element.text!.toUpperCase().contains(searchTerm.toUpperCase()))
        .toList());

    log("${lettersAndNatp.length}");
    log("lettersAnd natp length has been printed");
    if (lettersAndNatp.length > 0) return lettersAndNatp;

    return lettersAndNatp;
  }

  Future<List<Word>> getWords(String load) async {
    print("🔥 getWords() called for load: $load");
    print("Platform: ${kIsWeb ? 'Web' : 'Mobile'}");

    List<Word> words = [];

    // // --- Web version: Firebase only ---
    // if (kIsWeb) {
    //   print("🌐 Web detected — fetching directly from Firebase...");
    //   try {
    //     DatabaseEvent snap = await _database.ref(load).orderByValue().once();
    //     var keys = snap.snapshot.children;

    //     print("Total items fetched from Firebase: ${keys.length}");

    //     for (DataSnapshot key in keys) {
    //       var data = json.decode(json.encode(key.value));

    //       Word d = Word();
    //       d.file = data['file'] ?? "";
    //       d.pronun = data['pronun'] ?? "";
    //       d.syllables = data['syllables']?.toString() ?? "";
    //       d.text = data['text']?.toString() ?? "";
    //       d.cat = load;
    //       d.isFav = 0;
    //       d.isPriority = data['isPriority'] ?? "";

    //       words.add(d);
    //     }

    //     print("✅ Firebase words loaded successfully: ${words.length}");
    //   } catch (e, st) {
    //     print("❌ Error fetching words from Firebase (Web): $e");
    //     print(st);
    //   }

    //   return words;
    // }

    // --- Mobile version: Cached (Local DB + Firebase sync) ---
    print("📱 Mobile detected — checking local cache...");

    try {
      DatabaseProvider dbb = DatabaseProvider.get;
      WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);

      bool isSaved = await SharedPref.getSavedBool(load);
      print("isSaved (cached locally)? $isSaved");

      if (isSaved && !kIsWeb) {
        // ✅ Case 1: Already cached locally
        print("📦 Loading words from local database...");
        List<Word> wordsList = await dbRef.getWords();
        words = wordsList.where((element) => element.cat == load).toList();
        print("✅ Loaded ${words.length} words from local DB");
      } else {
        // ✅ Case 2: Not cached → Fetch from Firebase + Save locally
        print("☁️ Fetching words from Firebase for category: $load");

        await _database
            .ref(load)
            .orderByValue()
            .once()
            .then((DatabaseEvent snap) async {
          var keys = snap.snapshot.children;
          print("Total Firebase items: ${keys.length}");
          words.clear();

          for (DataSnapshot key in keys) {
            var data = json.decode(json.encode(key.value));

            Word d = Word();
            d.file = data['file'] ?? "";
            d.pronun = data['pronun'] ?? "";
            d.syllables = data['syllables']?.toString() ?? "";
            d.text = data['text']?.toString() ?? "";
            d.cat = load;
            d.isFav = 0;
            d.isPriority = data['isPriority'] ?? "";

            print("⬇️ Inserting word into local DB: ${d.text}");
            await dbRef.insert(d);
          }

          // Fetch back from local DB to confirm save
          if (keys.isNotEmpty) {
            List<Word> wordsList = await dbRef.getWords();
            words = wordsList.where((e) => e.cat == load).toList();
            print("✅ Words fetched from local DB after sync: ${words.length}");

            await SharedPref.saveBool(load, true); // Mark as saved
          } else {
            print("⚠️ No data found in Firebase for load: $load");
          }
        });
      }
    } catch (e, st) {
      print("❌ Error in getWords(): $e");
      print(st);
    }

    print("📤 Returning ${words.length} words total");
    return words;
  }

  Future<List<Word>> getWordsForSounds(
      String load, List<Word> wordsList) async {
    print("load");
    print("load is:$load");
    print(
        "databaseProviderCalledddd>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    List<Word> words = [];
    DatabaseProvider dbb = DatabaseProvider.get;
    WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
    bool isSaved = await SharedPref.getSavedBool(load);
    if (kIsWeb) {
      final CollectionReference wordsRef =
          firestore.collection('WordsForSounds').doc(load).collection('items');

      // if (isSaved) {
      print('✅ Loading "$load" from Firestore cache...');
      final snapshot = await wordsRef.get();
      if (snapshot.docs.isNotEmpty) {
        words = snapshot.docs
            .map((doc) => Word.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        print('✅ Fetched ${words.length} words from Firestore.');
        // } else {
        //   print('⚠️ No cached Firestore data found.');
        //   isSaved = false;
        // }
      }
    } else if (isSaved) {
      print('if is working');
      List<Word> wordsListss = await dbRef.getWords();
      words = wordsListss.where((element) => element.cat == load).toList();
      print('word id for sounds is :${words[1].id}');
    } else {
      print('else is working');
      print('words list lenght :${wordsList.length}');
      words.clear();
      for (var i = 0; i < wordsList.length; i++) {
        Word word = Word(
            file: wordsList[i].file ?? "",
            pronun: wordsList[i].pronun ?? "",
            syllables: wordsList[i].syllables ?? "",
            text: wordsList[i].text ?? "",
            cat: load,
            isFav: 0);
        await dbRef.insert(word);
        // words.add(word);
      }
      if (wordsList.length > 0) {
        List<Word> wordsList = await dbRef.getWords();
        print('words list length :${wordsList.length}');
        words = wordsList.where((element) => element.cat == load).toList();
        SharedPref.saveBool(load, true);
      }
    }
    return words;
  }

  Future<List<SentenceCat>> getSentencesCat(String load, String main) async {
    print(load);

    List<SentenceCat> sentenceCats = [];

    await _database
        .ref()
        .child(main)
        .child(load)
        .once()
        .then((DatabaseEvent snap) {
      var keys = snap.snapshot.children;
      // var data = snap.value;
      sentenceCats.clear();

      for (var key in keys) {
        SentenceCat d = new SentenceCat();
        d.title = key.key;

        sentenceCats.add(d);
      }
    });

    return sentenceCats;
  }

  Future<List<Sentence>> getFollowUps(
      String main, String sub, String load) async {
    print(load);

    List<Sentence> followUps = [];
    if (kIsWeb) {
      print("🌐 Fetching sentences (web) directly from Firebase...");
      try {
        DatabaseEvent snap =
            await _database.ref().child(main).child(sub).child(load).once();
        var keys = snap.snapshot.children;

        for (var key in keys) {
          var data = json.decode(json.encode(key.value));
          Sentence d = Sentence();
          d.id = 0;
          d.file = data['file'] ?? "";
          d.text = data['text'] ?? "";
          d.cat = load;
          d.isFav = 0;
          d.isPriority = data['isPriority'] ?? "";
          followUps.add(d);
        }

        print("✅ Loaded ${followUps.length} sentences (web)");
      } catch (e, st) {
        print("❌ Error fetching sentences (web): $e");
        print(st);
      }

      return followUps;
    }
    SentDatabaseProvider dbb = SentDatabaseProvider.get;
    SentencesDatabaseRepository dbRef = SentencesDatabaseRepository(dbb);

    bool isSaved = await SharedPref.getSavedBool(main);
    print("${isSaved}");
    if (isSaved) {
      print("call flow pratice lab");
      print("${isSaved}");
      List<Sentence> wordsList = await dbRef.getWords();
      print("${wordsList.length}");

      bool isContainscat = wordsList.any((element) => element.cat == load);

      if (isContainscat) {
        followUps = wordsList.where((element) => element.cat == load).toList();
      } else {
        print('////////////////NOT containing Cat');
        await _database
            .ref()
            .child(main)
            .child(sub)
            .child(load)
            //.orderByKey()
            .once()
            .then((DatabaseEvent snap) async {
          var keys = snap.snapshot.children;
          log("${keys}");
          // var data = snap.value;
          followUps.clear();

          for (var key in keys) {
            var data = json.decode(json.encode(key.value));
            Sentence d = new Sentence();
            d.file = data['file'] ?? "";
            d.text = data['text'] ?? "";
            d.cat = load;
            d.isFav = 0;
            d.isPriority = data['isPriority'] ?? "";

            dbRef.insert(d);
            // followUps.add(d);
          }

          if (keys.length > 0) {
            List<Sentence> wordsList = await dbRef.getWords();
            followUps =
                wordsList.where((element) => element.cat == load).toList();
            SharedPref.saveBool(main, true);
          }
        });
      }

      // print('CONTAINS : : : ${followUps.any((element) => element.cat == load)}');

      // followUps = wordsList;
    } else {
      log("else no call flow pratice lab");
      await _database
          .ref()
          .child(main)
          .child(sub)
          .child(load)
          //.orderByKey()
          .once()
          .then((DatabaseEvent snap) async {
        var keys = snap.snapshot.children;
        log("${keys}");
        // var data = snap.value;
        followUps.clear();

        for (var key in keys) {
          var data = json.decode(json.encode(key.value));
          Sentence d = new Sentence();
          d.file = data['file'] ?? "";
          d.text = data['text'] ?? "";
          d.cat = load;
          d.isFav = 0;
          d.isPriority = data['isPriority'] ?? "";

          dbRef.insert(d);
          // followUps.add(d);
        }

        if (keys.length > 0) {
          List<Sentence> wordsList = await dbRef.getWords();
          followUps =
              wordsList.where((element) => element.cat == load).toList();
          SharedPref.saveBool(main, true);
        }
      });
    }
    print(followUps.length);

    return followUps;
  }

  Future<List<Sentence>> getSentences(
      String load, String main, String cat) async {
    print(load);

    List<Sentence> sentences = [];

    await _database
        .ref()
        .child(main)
        .child(load)
        .child(cat)
        .orderByKey()
        .once()
        .then((DatabaseEvent snap) {
      var keys = snap.snapshot.children;
      // var data = snap.value;
      sentences.clear();

      for (var key in keys) {
        Sentence d = new Sentence();
        d.file = key.child('file').toString();
        d.text = key.child('text').toString();

        sentences.add(d);
      }
    });
    return sentences;
  }
}
