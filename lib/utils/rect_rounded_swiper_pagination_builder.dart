import 'dart:developer';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';

class RectRoundedSwiperPaginationBuilder extends SwiperPlugin {
  const RectRoundedSwiperPaginationBuilder({
    this.activeColor,
    this.color,
    this.key,
    this.size = const Size(10.0, 2.0),
    this.activeSize = const Size(10.0, 2.0),
    this.space = 3.0,
  });

  ///color when current index,if set null , will be Theme.of(context).primaryColor
  final Color? activeColor;

  ///,if set null , will be Theme.of(context).scaffoldBackgroundColor
  final Color? color;

  ///Size of the rect when activate
  final Size activeSize;

  ///Size of the rect
  final Size size;

  /// Space between rects
  final double space;

  final Key? key;

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    final themeData = Theme.of(context);
    final activeColor = this.activeColor ?? themeData.primaryColor;
    final color = this.color ?? themeData.scaffoldBackgroundColor;

    final list = <Widget>[];

    final itemCount = config.itemCount;
    final activeIndex = config.activeIndex;
    if (itemCount > 20) {
      log(
        'The itemCount is too big, we suggest use FractionPaginationBuilder '
        'instead of DotSwiperPaginationBuilder in this situation',
      );
    }

    for (var i = 0; i < itemCount; ++i) {
      final active = i == activeIndex;
      final size = active ? activeSize : this.size;
      list.add(SizedBox(
        width: size.width,
        height: size.height,
        child: Container(
          decoration: BoxDecoration(
            color: active ? activeColor : color,
            borderRadius: BorderRadius.circular(30)
          ),
          key: Key('pagination_$i'),
          margin: EdgeInsets.all(space),
        ),
      ));
    }

    if (config.scrollDirection == Axis.vertical) {
      return Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    } else {
      return Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    }
  }
}
