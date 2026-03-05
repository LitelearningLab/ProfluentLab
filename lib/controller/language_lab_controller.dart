import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/sound_model.dart';
import '../constants/app_colors.dart';

class LanguageLabController extends GetxController {
  int selectedIndex = 0;
  bool isLoading = true;
  bool isExpanded = false;
  int expandedIndex = -1;
  int subSelectedIndex = -1;
  int expandedVowelIndex = -1;
  int expandedConsonantIndex = -1;

  List<SoundModel> soundPageModel = [];
  SoundModel? importantSound;
  List<SoundModel> vowelSoundsList = [];
  List<SoundModel> consonantSoundsList = [];
  Map<String, dynamic>? languageLabStatus;

  List<Color> colorList = [
    Color(0xFF5AB963),
    Color(0xFFDDD639),
    Color(0xFF9C2780),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF5AB963),
    Color(0xFFDDD639),
    Color(0xFF9C2780),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchAndCategorizeSounds();
    fetchInReviewStatus();
  }

  void ontapTab(int index) {
    selectedIndex = index;
    update();
  }

  Future<void> fetchInReviewStatus() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('LanguageLabInReview')
          .get();

      if (snapshot.docs.isNotEmpty) {
        languageLabStatus = snapshot.docs.first.data();
        update();
      }
    } catch (e) {
      print('Error fetching status: $e');
    }
  }

  void showReviewPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        alignment: Alignment.center,
        title: const Text('Section Under Review'),
        content: const Text(
          'This section is temporarily under review. We’ll inform you as soon as it’s available again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.linearColor),
            ),
          ),
        ],
      ),
    );
  }

  bool isLabActive(String labKey) {
    if (languageLabStatus == null) return false;
    return (languageLabStatus![labKey] ?? '') == 'active';
  }

  Future<void> fetchAndCategorizeSounds() async {
    try {
      isLoading = true;
      update();

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Note: The collection name in source was 'profluentEnglish'
      final QuerySnapshot snapshot =
          await firestore.collection('profluentEnglish').get();

      soundPageModel.clear();
      vowelSoundsList.clear();
      consonantSoundsList.clear();
      importantSound = null;

      for (var doc in snapshot.docs) {
        try {
          final data = SoundModel.fromJson(doc.data() as Map<String, dynamic>);
          soundPageModel.add(data);

          final category = data.category.trim().toLowerCase();

          if (category.contains("important")) {
            importantSound = data;
            log("sound page model practice section practice length ${data.subcategories[0].soundsPractice?.length}");
          } else if (category == 'short vowel' ||
              category == 'long vowels' ||
              category == 'diphthong') {
            vowelSoundsList.add(data);
          } else if (category.startsWith("consonants")) {
            consonantSoundsList.add(data);
            log("${data.category}");
          }
        } catch (e) {
          log("❌ Error parsing doc ${doc.id}: $e");
        }
      }

      soundPageModel.sort((a, b) => a.order.compareTo(b.order));

      log("Total categories: ${soundPageModel.length}");
      log("Vowel models: ${vowelSoundsList.length}");
      log("Consonant models: ${consonantSoundsList.length}");
      log("Important sound present: ${importantSound != null}");

      isLoading = false;
      update();
    } catch (e) {
      log("Error fetching data: $e");
      isLoading = false;
      update();
    }
  }
}
