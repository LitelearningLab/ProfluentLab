import 'package:flutter/material.dart';

class Bubble {
  const Bubble({
    required this.title,
    required this.icon,
    required this.onPress,
  });

  final IconData icon;
  final void Function() onPress;
  final String title;
}

class BubbleMenu extends StatelessWidget {
  const BubbleMenu(this.item, {Key? key}) : super(key: key);

  final Bubble item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: InkWell(
        onTap: item.onPress,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.title,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Container(
              padding: EdgeInsets.all(12),
              decoration:
                  BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                item.icon,
                color: Colors.grey,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultHeroTag {
  const _DefaultHeroTag();
  @override
  String toString() => '<default FloatingActionBubble tag>';
}

class FloatingActionBubble extends AnimatedWidget {
  const FloatingActionBubble({
    Key? key,
    required this.items,
    required this.onPress,
    required this.iconColor,
    required this.backGroundColor,
    required Animation animation,
    this.heroTag,
    this.iconData,
    this.animatedIconData,
  })  : assert((iconData == null && animatedIconData != null) ||
            (iconData != null && animatedIconData == null)),
        super(listenable: animation, key: key);

  final List<Bubble> items;
  final void Function() onPress;
  final AnimatedIconData? animatedIconData;
  final Object? heroTag;
  final IconData? iconData;
  final Color iconColor;
  final Color backGroundColor;

  get _animation => listenable;

  Widget buildItem(BuildContext context, int index) {
    final screenWidth = MediaQuery.of(context).size.width;

    TextDirection textDirection = Directionality.of(context);

    double animationDirection = textDirection == TextDirection.ltr ? -1 : 1;

    final transform = Matrix4.translationValues(
      animationDirection *
          (screenWidth - _animation.value * screenWidth) *
          ((items.length - index) / 4),
      0.0,
      0.0,
    );

    return Align(
      alignment: textDirection == TextDirection.ltr
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Transform(
        transform: transform,
        child: Opacity(
          opacity: _animation.value,
          child: BubbleMenu(items[index]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IgnorePointer(
          ignoring: _animation.value == 0,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12.0),
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: items.length,
            itemBuilder: buildItem,
          ),
        ),
        FloatingActionButton(
          heroTag: heroTag ?? const _DefaultHeroTag(),
          backgroundColor: Colors.transparent,
          // iconData is mutually exclusive with animatedIconData
          // only 1 can be null at the time
          child: iconData == null
              ? AnimatedIcon(
                  icon: animatedIconData!,
                  progress: _animation,
                  color: iconColor,
                )
              : Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      shape: BoxShape.circle,
                      color: Colors.transparent),
                ),
          onPressed: onPress,
        ),
      ],
    );
  }
}
