import 'package:flutter/material.dart';

class WebHoverListItem extends StatefulWidget {
  final VoidCallback onTap;
  final String title;
  final bool isSelected;
  final bool hasLink;

  const WebHoverListItem({
    Key? key,
    required this.onTap,
    required this.title,
    this.isSelected = false,
    this.hasLink = true,
  }) : super(key: key);

  @override
  State<WebHoverListItem> createState() => _WebHoverListItemState();
}

class _WebHoverListItemState extends State<WebHoverListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          widget.hasLink ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.hasLink ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color(0xFF6C63FE).withValues(alpha: 0.04)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFF6C63FE).withValues(alpha: 0.1)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isHovered ? 4 : 0,
                      height: 24,
                      margin: EdgeInsets.only(right: _isHovered ? 16 : 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FE),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 18,
                          fontWeight:
                              _isHovered ? FontWeight.w800 : FontWeight.w600,
                          letterSpacing: -0.2,
                          color: widget.isSelected || _isHovered
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFF4A4A4A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.hasLink)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  transform:
                      Matrix4.translationValues(_isHovered ? 5 : 0, 0, 0),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 22,
                    color: _isHovered
                        ? const Color(0xFF6C63FE)
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
