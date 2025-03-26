import 'package:flutter/material.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';

class SubMenuItem extends StatelessWidget {
  SubMenuItem(
      {Key? key,
      required this.menuText,
      required this.image,
      required this.backgroundImage,
      this.onTap})
      : super(key: key);
  final String menuText;
  final String image;
  final String backgroundImage;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // image: DecorationImage(
          //   image: AssetImage(backgroundImage),
          //   fit: BoxFit.fill,
          // ),
        ),
        child: Row(
          children: [
            SPW(10),
            Image.asset(
              image,
              width: 35,
              height: 35,
              color: Color(0xff7ab800),
            ),
            SPW(10),
            Flexible(
              child: Text(
                menuText.toUpperCase(),
                style: TextStyle(
                    color: AppColors.black,
                    fontFamily: Keys.fontFamily,
                    fontWeight: FontWeight.w500,
                    fontSize: displayWidth(context) * 0.04),
              ),
            ),
          ],
        ),
        height: 50,
      ),
    );
  }
}
