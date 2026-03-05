import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';

class QuickLinksTile extends StatefulWidget {
  final String title;
  final String subTitle;
  final String imageUrl;
  final Color bgColor;
  final Function onTap;

  const QuickLinksTile({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.imageUrl,
    required this.bgColor,
    required this.onTap,
  }) : super(key: key);

  @override
  State<QuickLinksTile> createState() => _QuickLinksTileState();
}

class _QuickLinksTileState extends State<QuickLinksTile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isHovered ? Colors.white.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: widget.bgColor,
                  shape: BoxShape.circle,
                  boxShadow: isHovered
                      ? [
                          BoxShadow(
                            color: widget.bgColor.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                height: kIsWeb ? 52 : getWidgetHeight(height: 48),
                width: kIsWeb ? 52 : getWidgetWidth(width: 48),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    widget.imageUrl,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.2,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subTitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isHovered ? 1.0 : 0.0,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.only(right: isHovered ? 8 : 0),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF8B85FF),
                    size: 16,
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
