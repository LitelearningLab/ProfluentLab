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
import 'package:litelearninglab/models/ProfluentEnglish.dart';
import 'package:litelearninglab/models/ProfluentLink.dart';
import 'package:litelearninglab/screens/fast_track_pronunciation/fast_track_pronunciation_screen.dart';
import 'package:litelearninglab/screens/grammer_check/grammer_check_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/screens/profluent_english/lab_screen.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/models/sound_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageLabScreen extends StatelessWidget {
  const LanguageLabScreen({super.key});

  static const double _soundCardHeight = 420;

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 24),
                if (controller.fastTrackArModel != null)
                  _FastTrackArCard(model: controller.fastTrackArModel!),
                const SizedBox(height: 24),
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
        _categoryCard(context, controller,
            title: "Pronunciation Lab",
            image: AllAssets.pePl,
            color: const Color(0xFF398480),
            keyName: "english_lab"),
        _categoryCard(context, controller,
            title: "Sentence Lab",
            image: AllAssets.peScl,
            color: const Color(0xFF445EA9),
            keyName: "sentence_lab"),
        _categoryCard(context, controller,
            title: "Call Flow Lab",
            image: AllAssets.peCfpl,
            color: const Color(0xFF636CFF),
            keyName: "call_flow_lab"),
        _categoryCard(context, controller,
            title: "Grammar Lab",
            image: AllAssets.peGl,
            color: const Color(0xFFDC6379),
            keyName: "grammer_lab"),
      ],
    );
  }

  Widget _categoryCard(
    BuildContext context,
    LanguageLabController controller, {
    required String title,
    required String image,
    required Color color,
    required String keyName,
  }) {
    final auth = Provider.of<AuthState>(context, listen: false);

    return PETopCategoriesCard(
      title: title,
      imageUrl: image,
      cardColor: color,
      isUnderConstruction: false,
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        if (keyName == "english_lab") {
          await prefs.setString('lastAccess', 'LabScreen');
          await prefs.setStringList('LabScreen', [
            'Pronunciation Lab',
            auth.pronunciationLabList.join(',,'),
            'true'
          ]);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LabScreen(
                pLIconKey: true,
                user: auth,
                title: 'Pronunciation Lab',
                itemList: auth.pronunciationLabList,
              ),
            ),
          );
        } else if (keyName == "sentence_lab") {
          await prefs.setString('lastAccess', 'LabScreen');
          await prefs.setStringList('LabScreen', [
            'Sentence Lab',
            auth.sentenceConstructionLabList.join(',,'),
            'true'
          ]);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LabScreen(
                pLIconKey: true,
                user: auth,
                title: 'Sentence Lab',
                itemList: auth.sentenceConstructionLabList,
              ),
            ),
          );
        } else if (keyName == "call_flow_lab") {
          await prefs.setString('lastAccess', 'LabScreen');
          await prefs.setStringList('LabScreen', [
            'Call Flow Lab',
            auth.callFlowPracticeLabList.join(',,'),
            'true'
          ]);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LabScreen(
                pLIconKey: true,
                user: auth,
                title: 'Call Flow Lab',
                itemList: auth.callFlowPracticeLabList,
              ),
            ),
          );
        } else if (keyName == "grammer_lab") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GrammerCheckScreen()),
          );
        }
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

  static ProfluentEnglish _mapSoundModelToProfluentEnglish(SoundModel model) {
    return ProfluentEnglish(
      category: model.category,
      subcategories: model.subcategories.map((sub) {
        return ProfluentLink(
          name: sub.name,
          ulr: sub.ULR,
          videoLink:
              sub.ULR, // Assuming ULR contains the video link for Fast Track
          links: ProfluentSubLink(
            v1: sub.links.v1,
            v2: sub.links.v2,
            v3: sub.links.v3,
            v4: sub.links.v4,
            v5: sub.links.v5,
          ),
          soundsPractice: sub.soundsPractice?.map((sp) {
            return SoundPracticeModel(
              file: sp.file,
              pronun: sp.pronun,
              syllabels: sp.syllables,
              text: sp.text,
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _FastTrackArCard extends StatefulWidget {
  final SoundModel model;

  const _FastTrackArCard({required this.model});

  @override
  State<_FastTrackArCard> createState() => _FastTrackArCardState();
}

class _FastTrackArCardState extends State<_FastTrackArCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => fastTrackPronunciationScreen(
                title: LanguageLabScreen._mapSoundModelToProfluentEnglish(
                    widget.model),
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
          height: 110,
          width: double.infinity,
          transform: Matrix4.identity()..scale(_isHovered ? 1.012 : 1.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFF6C63FE).withOpacity(0.4)
                  : Colors.white.withOpacity(0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0xFF6C63FE).withOpacity(0.2)
                    : Colors.black.withOpacity(0.08),
                blurRadius: _isHovered ? 30 : 15,
                spreadRadius: _isHovered ? 2 : 0,
                offset: _isHovered ? const Offset(0, 10) : const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -30,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? const Color(0xFF6C63FE).withOpacity(0.08)
                          : const Color(0xFF6C63FE).withOpacity(0.03),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FE).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "FEATURED CONTENT",
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: const Color(0xFF6C63FE),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fast Track Pronunciation For AR',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      AnimatedScale(
                        duration: const Duration(milliseconds: 400),
                        scale: _isHovered ? 1.08 : 1.0,
                        curve: Curves.easeOutBack,
                        child: Image.asset(
                          AllAssets.peFtpfar,
                          height: 90,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
