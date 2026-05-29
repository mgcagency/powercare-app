


import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/widget/custom_text.dart';
import '../../../core/navigation/app_navigator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<Map<String, String>> _introData = [
    {"type": "logo", "image": "assets/icons/splash_logo.svg"},

    {
      "type": "intro",
      "title": "Track Progress",
      "subtitle": "Monitor student performance in real-time.",
      "image": "assets/images/intro2.png",
    },
    {
      "type": "intro",
      "title": "Stay Connected",
      "subtitle": "Communication between teachers and parents made easy.",
      "image": "assets/images/intro3.png",
    },
    {
      "type": "intro",
      "title": "Manage Attendance",
      "subtitle": "Easy tracking of student presence and leave requests.",
      "image": "assets/images/intro4.png",
    },
    {
      "type": "intro",
      "title": "Stay Notified",
      "subtitle": "Get instant updates about exams, events, and results.",
      "image": "assets/images/intro5.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    // _checkLoginStatus();
    _startAutoScroll();
  }


  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _introData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _introData.length,
            itemBuilder: (context, index) {
              final item = _introData[index];

              if (item["type"] == "logo") {
                return Center(child: SvgPicture.asset(item["image"]!));
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image.asset(item["image"]!, height: 300),
                  const SizedBox(height: 40),
                  CustomText(
                    item["title"]!,
                    style: AppTextStyles.headline2.copyWith(
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: CustomText(
                      item["subtitle"]!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _introData.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 6),
                  height: 6,
                  width: _currentPage == index ? 18 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: GestureDetector(
              onTap: () async {

                  // AppNavigator.pushAndRemoveAll();

              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    "Sign In",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
