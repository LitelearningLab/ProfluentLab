// import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';

// import 'package:litelearninglab/constants/all_assets.dart';
//
class PETopCategoriesCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final Function onTap;
  final Color cardColor;
  final double height;
  final double width;
  const PETopCategoriesCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
    required this.cardColor,
    required this.height,
    required this.width,
    Key? key,
  }) : super(key: key);

  @override
  State<PETopCategoriesCard> createState() => _PETopCategoriesCardState();
}

class _PETopCategoriesCardState extends State<PETopCategoriesCard> {
  @override
  void initState() {
    super.initState();
    // startTimerMainCategory("name");
    subCategoryTitile = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final textscalar = MediaQuery.of(context).textScaler;
    return InkWell(
      onTap: () {
        widget.onTap();
      },
      child: Container(
        padding: EdgeInsets.only(
          left: 10,
          top: 12,
        ),
        height: getWidgetHeight(height: 147),
        width: kIsWeb ? size.width * 0.2 : size.width * 0.45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.cardColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  letterSpacing: 0,
                )
                // textScaler: textscalar,
                ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                  height: widget.height,
                  width: widget.width,
                  // decoration: BoxDecoration(
                  //   image: DecorationImage(image: AssetImage(imageUrl),fit: BoxFit.fitHeight)
                  // ),
                  child: Image.asset(
                    widget.imageUrl,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
