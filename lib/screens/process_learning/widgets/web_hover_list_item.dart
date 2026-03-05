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
        onTap: widget.hasLink ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color(0xFFF8F9FA) // Lighter grey/blue on hover
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16, // slightly larger
                    fontWeight: FontWeight.w600, // bolder
                    color: widget.isSelected
                        ? const Color(0xFF6C63FE)
                        : const Color(0xFF2D2D2D), // darker inactive
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
