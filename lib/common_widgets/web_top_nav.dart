import 'package:flutter/material.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:provider/provider.dart';

class WebHeaderWithNav extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function? onBack;
  final Function? onDrawer;
  final String? appbarIcon;

  const WebHeaderWithNav({
    Key? key,
    required this.title,
    this.onBack,
    this.onDrawer,
    this.appbarIcon,
  }) : super(key: key);

  bool get isHome =>
      title.toLowerCase() == "home" || title.toLowerCase() == "dashboard";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Color(0xFF293750), // Using theme color from app
        border: Border(
          bottom: BorderSide(color: Color(0xFF34425D)),
        ),
      ),
      child: Row(
        children: [
          /// ---------------- LEFT SECTION ----------------
          if (!isHome) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (onBack != null) {
                  onBack!();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            if (appbarIcon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                height: 35,
                width: 35,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF584EFF),
                      Color(0xFF6C63FE),
                    ],
                  ),
                ),
                child: Image.asset(
                  appbarIcon!,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ] else ...[
            Row(
              children: [
                const Text("PROFLUENT",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: "Quicksand",
                        letterSpacing: 2)),
                const SizedBox(width: 8),
                Container(
                  height: 35,
                  child: Image.asset(
                    "assets/images/profluent_ar_icon.png",
                    height: 35,
                    width: 35,
                  ),
                ),
              ],
            ),
          ],

          const Spacer(),

          /// ---------------- NAV ITEMS ----------------
          Consumer<AuthState>(
            builder: (context, authState, _) {
              return Row(
                children: [
                  _navItem(
                    label: "Home",
                    icon: AllAssets.bottomHome,
                    index: 0,
                    context: context,
                    currentIndex: authState.currentIndex,
                  ),
                  _navItem(
                    label: "Process Learning",
                    icon: AllAssets.bottomPL,
                    index: 1,
                    context: context,
                    currentIndex: authState.currentIndex,
                  ),
                  _navItem(
                    label: "Simulations",
                    icon: AllAssets.bottomIS,
                    index: 2,
                    context: context,
                    currentIndex: authState.currentIndex,
                  ),
                  _navItem(
                    label: "Language Lab",
                    icon: AllAssets.bottomPE,
                    index: 3,
                    context: context,
                    currentIndex: authState.currentIndex,
                  ),
                  _navItem(
                    label: "Reports",
                    icon: AllAssets.bottomPT,
                    index: 4,
                    context: context,
                    currentIndex: authState.currentIndex,
                  ),
                ],
              );
            },
          ),

          if (isHome)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: onDrawer != null ? () => onDrawer!() : null,
            ),
        ],
      ),
    );
  }

  Widget _navItem({
    required String label,
    required String icon,
    required int index,
    required BuildContext context,
    required int currentIndex,
  }) {
    final active = currentIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        Provider.of<AuthState>(context, listen: false).changeIndex(index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            ImageIcon(
              AssetImage(icon),
              size: 18,
              color: active ? Colors.white : const Color(0xFFAAAAAA),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : const Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
