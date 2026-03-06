import 'package:flutter/material.dart';

class WebHoverCard extends StatefulWidget {
  final VoidCallback onTap;
  final Color tileColor;
  final String tileImage;
  final String heading;
  final String category;
  final Color headingColor;

  const WebHoverCard({
    Key? key,
    required this.onTap,
    required this.tileColor,
    required this.tileImage,
    required this.heading,
    required this.category,
    required this.headingColor,
  }) : super(key: key);

  @override
  State<WebHoverCard> createState() => _WebHoverCardState();
}

class _WebHoverCardState extends State<WebHoverCard> {
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
          curve: Curves.easeOutQuart,
          transform: Matrix4.identity()
            ..translate(0, _isHovered ? -12.0 : 0)
            ..scale(_isHovered ? 1.02 : 1.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered
                  ? widget.tileColor.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.tileColor.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: _isHovered ? 40 : 20,
                spreadRadius: _isHovered ? 2 : 0,
                offset: _isHovered ? const Offset(0, 15) : const Offset(0, 10),
              ),
              if (_isHovered)
                BoxShadow(
                  color: widget.tileColor.withValues(alpha: 0.1),
                  blurRadius: 60,
                  spreadRadius: -5,
                ),
            ],
          ),
          width: 320,
          height: 380,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Top indicator line replaced with a more subtle gradient
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.tileColor,
                          widget.tileColor.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: widget.tileColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              widget.heading.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 1.2,
                                color: widget.headingColor,
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _isHovered ? 1.0 : 0.0,
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: widget.headingColor,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 400),
                              scale: _isHovered ? 1.1 : 1.0,
                              curve: Curves.easeOutBack,
                              child: widget.tileImage.isNotEmpty
                                  ? Image.asset(
                                      widget.tileImage,
                                      fit: BoxFit.contain,
                                    )
                                  : const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              color: Color(0xFF1A1A1A),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 2,
                            width: _isHovered ? 40 : 0,
                            decoration: BoxDecoration(
                              color: widget.tileColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Transform.rotate(
                    angle: -0.05,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: ShapeDecoration(
                        color: Colors.amber.withOpacity(0.95),
                        shape: const StadiumBorder(),
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Text(
                        "WORKING IN PROGRESS",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
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
