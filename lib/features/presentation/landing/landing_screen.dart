import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rosewood/app/theme/colors.dart';
import 'package:rosewood/app/theme/text_styles.dart';
import 'package:rosewood/app/widget/custom_button.dart';
import 'package:rosewood/app/widget/custom_text.dart';
import 'package:rosewood/app/widget/custom_outline_button.dart';
import 'package:rosewood/core/navigation/app_navigator.dart';
import 'package:rosewood/features/auth/presentation/login_screen.dart';
import 'package:rosewood/features/landing/login_user.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/widget/custom_button.dart';
import '../../../app/widget/custom_outline_button.dart';
import '../../../app/widget/custom_text.dart';
import '../../../core/navigation/app_navigator.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/logo.svg',
                width: 120,
              ),
              const SizedBox(height: 40),
              CustomText(
                'Welcome to Rosewood Virtual Academy!',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CustomText(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.darkGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              CustomButton(
                title: 'Register',
                onPressed: () {
                  // Navigate to registration
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Container(
                      margin: const EdgeInsets.only(left: 50),
                      child: Divider(color: AppColors.grey))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomText(
                      'or',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
                    ),
                  ),
                  Expanded(child:Container(
                      margin: const EdgeInsets.only(right: 50),
                      child: Divider(color: AppColors.grey))),
                ],
              ),
              const SizedBox(height: 20),
              CustomOutlineButton(
                title: 'Already have an account? Sign in',
                onPressed: () {
                  AppNavigator.push(const LoginUserScreen());
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
