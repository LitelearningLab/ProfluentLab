import 'package:chewie/src/chewie_progress_colors.dart';
import 'package:chewie/src/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/screens/profluent_english/widgets/video_progress_controller.dart';
import 'package:video_player/video_player.dart';

class CustomMaterialVideoProgressBar extends StatelessWidget {
  CustomMaterialVideoProgressBar(
    this.controller, {
    this.height = kToolbarHeight,
    ChewieProgressColors? colors,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
    // super.key,
  }) : colors = colors ?? ChewieProgressColors();

  final double height;
  final VideoPlayerController controller;
  final ChewieProgressColors colors;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  final Function()? onDragUpdate;

  @override
  Widget build(BuildContext context) {
    return CustomVideoProgressBar(
      controller,
      barHeight: 5,
      handleHeight: 6,
      drawShadow: true,
      colors: colors,
      onDragEnd: onDragEnd,
      onDragStart: onDragStart,
      onDragUpdate: onDragUpdate,
    );
  }
}
