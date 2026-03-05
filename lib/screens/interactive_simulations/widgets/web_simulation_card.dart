import 'package:flutter/material.dart';

class WebSimulationCard extends StatefulWidget {
  final VoidCallback onTap;
  final Color tileColor;
  final String title;
  final String icon;
  final String ellipse;

  const WebSimulationCard({
    Key? key,
    required this.onTap,
    required this.tileColor,
    required this.title,
    required this.icon,
    required this.ellipse,
  }) : super(key: key);

  @override
  State<WebSimulationCard> createState() => _WebSimulationCardState();
}

class _WebSimulationCardState extends State<WebSimulationCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width:
              320, // To match the width of process learning cards or slightly wider
          height: 240,
          transform: Matrix4.translationValues(0, _isHovered ? -12.0 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.tileColor,
                widget.tileColor.withValues(alpha: 0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.tileColor.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: _isHovered ? 40 : 20,
                spreadRadius: _isHovered ? 8 : 0,
                offset: _isHovered ? const Offset(0, 20) : const Offset(0, 10),
              ),
            ],
          ).copyWith(
            // Adding a subtle inner border for premium look
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Ellipse/Background shape (Lower Left)
                Positioned(
                  bottom: -10,
                  left: -10,
                  child: Opacity(
                    opacity: 0.2, // Match the mock's subtle appearance
                    child: Image.asset(
                      widget.ellipse,
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Icon (Large and positioned bottom right)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: AnimatedScale(
                    scale: _isHovered ? 1.08 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    child: SizedBox(
                      width: 130,
                      height: 130,
                      child: Image.asset(
                        widget.icon,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                // Title (Top Left)
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Roboto',
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
