import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/colors.dart';

class AnimatedMicButton extends StatefulWidget {
  final VoidCallback startListening;
  final VoidCallback stopListening;
  final bool isListening;
  final bool isGeneratingAns;

  const AnimatedMicButton({
    super.key,
    required this.startListening,
    required this.stopListening,
    required this.isListening,
    required this.isGeneratingAns,
  });

  @override
  State<AnimatedMicButton> createState() => _AnimatedMicButtonState();
}

class _AnimatedMicButtonState extends State<AnimatedMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final int barCount = 4;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  void toggleListening() {
    if (!widget.isListening) {
      // START: reset then repeat
      controller.reset();
      controller.repeat();
      widget.startListening();
    } else {
      // STOP
      controller.stop();
      widget.stopListening();
    }


  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleListening,
      child: SizedBox(
        height: 60,
        width: 60,
        child: !widget.isListening  && widget.isGeneratingAns
            ? AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(barCount, (index) {
                final value = sin(controller.value * 2 * pi + index * 0.5);
                final height = 10 + (value.abs() * 20);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 4,
                  height: height,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primary,
                        blurRadius: 10,
                      )
                    ],
                  ),
                );
              }),
            );
          },
        ) :widget.isListening  && !widget.isGeneratingAns?Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          alignment: Alignment.center,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.stop,
            color: Colors.white,
            size: 30,
          ),
        )
            : Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.mic,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
