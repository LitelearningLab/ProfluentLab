// import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';

// import 'package:litelearninglab/constants/all_assets.dart';
//
class PETopCategoriesCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final Function onTap;
  final Color cardColor;
  final double? height;
  final double? width;
  final bool isUnderConstruction;

  const PETopCategoriesCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
    required this.cardColor,
    this.height,
    this.width,
    this.isUnderConstruction = false,
    Key? key,
  }) : super(key: key);

  @override
  State<PETopCategoriesCard> createState() => _PETopCategoriesCardState();
}

class _PETopCategoriesCardState extends State<PETopCategoriesCard> {
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // startTimerMainCategory("name");
    subCategoryTitile = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    // final textscalar = MediaQuery.of(context).textScaler;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: InkWell(
          onTap: () {
            widget.onTap();
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: widget.cardColor,
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: widget.cardColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: kIsWeb ? 18 : 16,
                          fontFamily: 'Roboto',
                          letterSpacing: 0,
                        )
                        // textScaler: textscalar,
                        ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                            height: widget.height,
                            width: widget.width,
                            child: Image.asset(
                              fit: BoxFit.contain,
                              widget.imageUrl,
                            )),
                      ),
                    )
                  ],
                ),
              ),
              if (widget.isUnderConstruction)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF34425D),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Under Review",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
