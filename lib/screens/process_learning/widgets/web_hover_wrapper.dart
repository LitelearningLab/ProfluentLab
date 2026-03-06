import 'package:flutter/material.dart';

class WebHoverWrapper extends StatefulWidget {
  final Widget child;
  final BoxDecoration? decoration;
  final BoxDecoration? hoverDecoration;
  final bool scaleOnHover;

  const WebHoverWrapper({
    Key? key,
    required this.child,
    this.decoration,
    this.hoverDecoration,
    this.scaleOnHover = true,
  }) : super(key: key);

  @override
  State<WebHoverWrapper> createState() => _WebHoverWrapperState();
}

class _WebHoverWrapperState extends State<WebHoverWrapper> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(widget.scaleOnHover && _isHovering ? 1.01 : 1.0),
        decoration: _isHovering && widget.hoverDecoration != null
            ? widget.hoverDecoration
            : widget.decoration,
        child: widget.child,
      ),
    );
  }
}
