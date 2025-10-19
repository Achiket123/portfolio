import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: LoadingAnimationWidget.dotsTriangle(
        color: const Color.fromARGB(255, 8, 70, 10),
        size: 40,
      ),
    );
  }
}
