import 'package:flutter/material.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';

class SecondRowMenu extends StatelessWidget {
  SecondRowMenu(
      {Key? key, required this.menuImage, required this.menu, this.onTap})
      : super(key: key);
  final String menuImage;
  final String menu;
  final GestureTapCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: 3, bottom: 2),
        width: displayWidth(context) * 0.49,
        height: displayWidth(context) * 0.32,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              menuImage,
              width: displayWidth(context) * 0.075,
              height: 30,
              color: Color(0xff7ab800),
              fit: BoxFit.fitWidth,
            ),
            SPH(8),
            Text(
              menu,
              style: TextStyle(
                  fontFamily: Keys.fontFamily,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  fontSize: displayWidth(context) * 0.035),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
