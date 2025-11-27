import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';

class QuickLinksTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final String imageUrl;
  final Color bgColor;
  final Function onTap;
  const QuickLinksTile(
      {Key? key,
      required this.title,
      required this.subTitle,
      required this.imageUrl,
      required this.bgColor,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Container(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              height: kIsWeb
                  ? getWidgetHeight(height: 50)
                  : getWidgetHeight(height: 42),
              width: kIsWeb
                  ? getWidgetWidth(width: 10)
                  : getWidgetWidth(width: 42),
              child: Padding(
                padding: EdgeInsets.all(kIsWeb ? 8 : 12.0),
                child: Image.asset(
                  imageUrl,
                  // scale: 3,
                ),
              ),
            ),
            // CircleAvatar(
            //   backgroundColor: bgColor,
            //   child: Padding(
            //     padding: const EdgeInsets.all(10.0),
            //     child: Image.asset(
            //       imageUrl,
            //       // scale: 3,
            //     ),
            //   ),
            // ),
            SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    letterSpacing: 0,
                    fontFamily: 'Roboto',
                  ),
                ),
                Text(
                  subTitle,
                  style: TextStyle(
                    color: const Color.fromARGB(125, 255, 255, 255),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: 0,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

    // ListTile(
    //   splashColor: Color(0xff34425D),
    //   leading: CircleAvatar(
    //     backgroundColor: bgColor,
    //     child: Padding(
    //       padding: const EdgeInsets.all(10.0),
    //       child: Image.asset(
    //         imageUrl,
    //         // scale: 3,
    //       ),
    //     ),
    //   ),
    //   title: Transform.translate(
    //     offset: Offset(-3,0),
    //     child: Text(
    //       title,
    //       style: TextStyle(
    //         color: Colors.white,
    //         fontWeight: FontWeight.w500,
    //         fontSize: 16,
    //         fontFamily: Keys.fontFamilyMedium,
    //         letterSpacing: 0,

    //       ),
    //     ),
    //   ),
    //   subtitle: Transform.translate(
    //     offset: Offset(-3, 0),
    //     child: Text(
    //       subTitle,
    //       style: TextStyle(
    //         color: const Color.fromARGB(125, 255, 255, 255),
    //         fontWeight: FontWeight.w500,
    //         fontFamily: Keys.fontFamily,
    //         fontSize: 14,
    //         letterSpacing: 0,
    //       ),
    //     ),
    //   ),
    //   onTap: () {
    //     onTap();
    //   },
    // );
  }
}
