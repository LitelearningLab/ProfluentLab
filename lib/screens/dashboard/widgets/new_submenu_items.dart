import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';

class NewSubMenuItem extends StatelessWidget {
  NewSubMenuItem(
      {Key? key,
      required this.menuText,
      required this.image,
      required this.backgroundImage,
      required this.bgColor,
      this.onTap})
      : super(key: key);
  final String menuText;
  final String image;
  final String backgroundImage;
  final GestureTapCallback? onTap;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    return InkWell(
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: displayWidth(context),
        padding: EdgeInsets.only(
            left:
                kIsWeb ? getWidgetWidth(width: 10) : getWidgetWidth(width: 20),
            right: getWidgetWidth(width: 20),
            top: 7.5,
            bottom: 7.5),
        // onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    height: getWidgetHeight(height: 36),
                    width: getWidgetWidth(width: kIsWeb ? 18 : 36),
                    decoration:
                        BoxDecoration(color: bgColor, shape: BoxShape.circle),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ImageIcon(
                        AssetImage(image),
                        color: Colors.white,
                      ),
                      // Image.asset(
                      //   image,
                      //   // scale: displayWidth(context)/101.5,
                      // ),
                    ),
                  ),
                  SizedBox(
                    width: kIsWeb ? 0 : getWidgetWidth(width: 10),
                  ),
                  Expanded(
                    child: Text(
                      menuText,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: kText.scale(15),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              // height: 30,
              // width: 30,
              child: Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF34445F),
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
