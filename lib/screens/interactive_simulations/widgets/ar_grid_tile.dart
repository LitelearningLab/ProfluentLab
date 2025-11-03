import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';

class ARGridTile extends StatelessWidget {
  final Function onTap;
  final Color tileColor;
  final String title;
  final String icon;
  final String ellipse;
  final double? height;
  final double? width;
  const ARGridTile(
      {required this.onTap,
      required this.tileColor,
      required this.title,
      required this.icon,
      required this.ellipse,
      this.height,
      this.width,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        // height: displayHeight(context) * 0.233,
        height: height ?? getWidgetHeight(height: 180),
        width: width ?? getWidgetWidth(width: 158),
        // padding: EdgeInsets.symmetric(
        //     horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: tileColor,
          //  gridTileDatas[0]['tileColor'],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10, right: 20),
                  child: Text(
                    title,
                    // _categories[index].category!,
                    // gridTileDatas[0]['title']!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10, bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      // height: displayHeight(context) * 0.061,
                      // width: displayWidth(context) * 0.133,
                      height: kIsWeb ? 120 : 50,
                      width: kIsWeb ? 120 : 50,
                      child: Image.asset(
                        icon,
                        // gridTileDatas[0]['image'],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                ),
                child: Image.asset(
                  ellipse,
                  // gridTileDatas[0]['ellipse'],
                  scale: kIsWeb ? 1.6 : 3.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
