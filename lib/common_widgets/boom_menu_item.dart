import 'package:flutter/material.dart';

/// Provides data for a speed dial child
class MenuItem {
  final Widget? child;
  final Color? backgroundColor;
  final double ?elevation;
  final VoidCallback ?onTap;
  final String? title;
  final Color? titleColor;
  final Color? subTitleColor;

  MenuItem(
      {this.child,
      required this.title,
      this.backgroundColor,
      this.elevation,
      this.onTap,
      this.titleColor,
      this.subTitleColor});
}
