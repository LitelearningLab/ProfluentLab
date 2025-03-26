import 'package:flutter/material.dart';

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final double? height;

  final Widget child;

  UserAppBar({Key? key, required this.child, this.height})
      : preferredSize = Size.fromHeight(height ?? 100.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
