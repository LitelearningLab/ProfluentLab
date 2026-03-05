import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/controller/language_lab_controller.dart';
import 'package:litelearninglab/screens/profluent_english/widgets/top_catetgories_card.dart';
import 'package:litelearninglab/screens/profluent_english/profluent_sub_screen.dart';
import 'package:litelearninglab/models/ProfluentSubLink.dart';
import 'package:litelearninglab/models/Word.dart' as ProWord;
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';

class LanguageLabScreen extends StatelessWidget {
  const LanguageLabScreen({super.key});

  static const double _soundCardHeight = 420;

  @override
  Widget build(BuildContext context) {
    // In ProfluentLab, we might not have a HomeController with loadRecentHistory,
    // but the source project's LanguageLab uses it.
    // I'll skip the PopScope part if HomeController is not found or needed.

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GetBuilder<LanguageLabController>(
        init: LanguageLabController(),
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.linearColor),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _categoryGrid(context, controller),
                const SizedBox(height: 12),
                Text(
                  "Sounds",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _soundSectionCard(
                        title: "Important Sounds",
                        child: _importantSounds(context, controller),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _soundSectionCard(
                        title: "Vowels",
                        child: _expandableSounds(
                          context,
                          controller,
                          controller.vowelSoundsList,
                          isVowel: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _soundSectionCard(
                        title: "Consonants",
                        child: _expandableSounds(
                          context,
                          controller,
                          controller.consonantSoundsList,
                          isVowel: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= CATEGORY GRID =================
  Widget _categoryGrid(BuildContext context, LanguageLabController controller) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.8,
      children: [
        _categoryCard(controller,
            title: "English Pronunciation",
            image: AllAssets.pePl,
            color: const Color(0xFF398480),
            keyName: "english_lab"),
        _categoryCard(controller,
            title: "French Pronunciation",
            image: AllAssets.peScl,
            color: const Color(0xFF445EA9),
            keyName: "french_lab"),
        _categoryCard(controller,
            title: "Sentence Lab",
            image: AllAssets.peCfpl,
            color: const Color(0xFF636CFF),
            keyName: "sentence_lab"),
        _categoryCard(controller,
            title: "Grammar Lab",
            image: AllAssets.peGl,
            color: const Color(0xFFDC6379),
            keyName: "grammer_lab"),
      ],
    );
  }

  Widget _categoryCard(
    LanguageLabController controller, {
    required String title,
    required String image,
    required Color color,
    required String keyName,
  }) {
    return PETopCategoriesCard(
      title: title,
      imageUrl: image,
      cardColor: color,
      isUnderConstruction: false,
      onTap: () {
        if (!controller.isLabActive(keyName)) {
          controller.showReviewPopup(Get.context!);
          return;
        }
        // In ProfluentLab, we'd navigate to the respective lab screens
        // mianCategoryTitile = title;
      },
      height: null,
      width: null,
    );
  }

  // ================= SOUND CARD =================
  Widget _soundSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      height: _soundCardHeight,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEDED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Expanded(child: child),
        ],
      ),
    );
  }

  // ================= IMPORTANT SOUNDS =================
  Widget _importantSounds(
      BuildContext context, LanguageLabController controller) {
    return ListView.separated(
      itemCount: controller.importantSound?.subcategories.length ?? 0,
      separatorBuilder: (_, __) => const Divider(color: Color(0xFFEDEDED)),
      itemBuilder: (context, index) {
        final item = controller.importantSound!.subcategories[index];

        return _soundTile(
          title: item.name,
          color: AppColors.linearColor,
          onTap: () {
            mianCategoryTitile = "Sounds";
            subCategoryTitile = item.name;

            _navigateToSubScreen(context, item);
          },
        );
      },
    );
  }

  // ================= EXPANDABLE =================
  Widget _expandableSounds(
    BuildContext context,
    LanguageLabController controller,
    List list, {
    required bool isVowel,
  }) {
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(color: Color(0xFFEDEDED)),
      itemBuilder: (context, index) {
        final isExpanded = isVowel
            ? controller.expandedVowelIndex == index
            : controller.expandedConsonantIndex == index;

        final sectionColor =
            controller.colorList[index % controller.colorList.length];

        return Column(
          children: [
            _soundTile(
              title: list[index].category,
              color: sectionColor,
              trailing: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey),
              onTap: () {
                if (isVowel) {
                  controller.expandedVowelIndex = isExpanded ? -1 : index;
                } else {
                  controller.expandedConsonantIndex = isExpanded ? -1 : index;
                }
                controller.update();
              },
            ),
            if (isExpanded)
              ...list[index].subcategories.map<Widget>((sub) {
                return Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: _soundTile(
                    title: sub.name,
                    color: sectionColor.withOpacity(0.35),
                    onTap: () {
                      mianCategoryTitile = list[index].category;
                      subCategoryTitile = sub.name;
                      _navigateToSubScreen(context, sub);
                    },
                  ),
                );
              }).toList(),
          ],
        );
      },
    );
  }

  // ================= TILE =================
  Widget _soundTile({
    required String title,
    required VoidCallback onTap,
    required Color color,
    Widget? trailing,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        hoverColor: Colors.white.withOpacity(0.1),
        splashColor: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color,
                child: const Text(
                  "En",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              trailing ??
                  const Icon(Icons.chevron_right,
                      color: Color(0xFF94A3B8), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSubScreen(BuildContext context, dynamic sub) {
    // Map sound_model's Links to ProfluentSubLink
    final proLink = ProfluentSubLink();
    proLink.v1 = sub.links.v1;
    proLink.v2 = sub.links.v2;
    proLink.v3 = sub.links.v3;
    proLink.v4 = sub.links.v4;
    proLink.v5 = sub.links.v5;

    // Map sound_model's SoundPractice to ProWord.Word
    final List<ProWord.Word> soundPracticeWords =
        (sub.soundsPractice as List?)?.map((sp) {
              return ProWord.Word(
                file: sp.file,
                pronun: sp.pronun,
                syllables: sp.syllables,
                text: sp.text,
              );
            }).toList() ??
            [];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfluentSubScreen(
          links: proLink,
          load: sub.name,
          title: sub.name,
          ulr: sub.ULR,
          soundPractice: soundPracticeWords,
        ),
      ),
    );
  }
}
