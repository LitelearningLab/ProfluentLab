import 'package:flutter/material.dart';

class AnimatedChild extends AnimatedWidget {
  final int index;
  final Color backgroundColor;
  final double? elevation;
  final Widget child;

  final bool visible;
  final VoidCallback onTap;
  final VoidCallback toggleChildren;
  final String title;
  final Color titleColor;
  final Color? subTitleColor;

  AnimatedChild({Key? key, required Animation<double> animation, required this.index, required this.backgroundColor, this.elevation = 6.0, required this.child, required this.title, this.visible = false, required this.onTap, required this.toggleChildren, required this.titleColor, this.subTitleColor})
      : super(key: key, listenable: animation);

  void _performAction() {
    onTap();
    toggleChildren();
  }

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;

    final Widget buttonChild = animation.value > 50.0
        ? Container(
          width: animation.value,
          height: animation.value,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: child,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: (titleColor == null) ? Colors.black : titleColor, fontSize: 16.0),
                  ),
                ),
              )
            ],
          ),
        )
        : Container(
            width: 0.0,
            height: 0.0,
          );

    return Container(
      width: MediaQuery.of(context).size.width - 30,
      height: 80.0,
      padding: EdgeInsets.only(bottom: 72 - animation.value),
      child: GestureDetector(
        onTap: _performAction,
        child: buttonChild,
      ),
    );
  }
}
