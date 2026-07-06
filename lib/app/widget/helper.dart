import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/navigation/app_navigator.dart';
import '../../features/presentation/jobs/job_sheet_screen.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'custom_text.dart';

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

class SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isJobSheet;
  final bool isAccepted;
  final Widget child;
  const SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.isJobSheet =false,
    this.isAccepted =false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBEBEB), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 17, color: AppColors.primary),
                const SizedBox(width: 7),
                CustomText(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if(isJobSheet)
                  Spacer(),
                if(isJobSheet && isAccepted)
                  GestureDetector(
                    onTap: () async {
                      AppNavigator.push(JobSheetScreen());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: child,
          ),
        ],
      ),
    );
  }
}

