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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                _isHovered ? BorderRadius.circular(12) : BorderRadius.zero,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 17,
                    fontWeight: _isHovered ? FontWeight.w700 : FontWeight.w600,
                    color: widget.isSelected
                        ? const Color(0xFF6C63FE)
                        : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              if (widget.hasLink)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: _isHovered
                      ? const Color(0xFF6C63FE)
                      : Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
