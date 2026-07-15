import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/storage/app_preferences.dart';
import '../dashboard/dashboard_screen.dart';
import 'authentication_screen.dart'; // If needed for KeypadButton

class ConfirmPinScreen extends StatefulWidget {
  final String originalPin;
  const ConfirmPinScreen({super.key, required this.originalPin});

  @override
  State<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends State<ConfirmPinScreen> with TickerProviderStateMixin {
  String pin = "";
  late AnimationController _animationController;
  late Animation<Offset> _sheetOffset;
  late Animation<double> _logoScale;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    // Entrance Animations
    _animationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _sheetOffset = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 1.0, curve: Curves.fastLinearToSlowEaseIn)),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.linear)),
    );

    // Error Shake Animation
    _shakeController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
  Future<void> verifyAndSavePin() async {
    if (pin == widget.originalPin) {
      HapticFeedback.heavyImpact();

      final email = await AppPreferences.getUserEmail() ?? "";
      print("EMAIL = $email");
      print("PIN = $pin");
      await AppPreferences.setSecretCode(
        email,
        pin,
      );

      print("PIN SAVED");
      if (mounted) {
        AppNavigator.pushAndRemoveAll(
          const DashboardScreen(),
        );
      }
    } else {
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0);
      setState(() => pin = "");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const CustomText(
            "PINs do not match. Try again.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
/*  Future<void> verifyAndSavePin() async {
    if (pin == widget.originalPin) {
      HapticFeedback.heavyImpact();
      // Save PIN to local storage
      await AppPreferences.setSecretCode(pin);

      if (mounted) {
        AppNavigator.pushAndRemoveAll(const DashboardScreen());
      }
    } else {
      // PINs don't match
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0);
      setState(() => pin = "");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const CustomText("PINs do not match. Try again."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: Stack(
        children: [
          _buildHeroSection(),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Positioned(
      top: 0, left: 0, right: 0,
      height: MediaQuery.of(context).size.height * 0.42,
      child: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/icons/login_bg.jpg', fit: BoxFit.cover)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.navyBlue.withOpacity(0.6), AppColors.navyBlue],
              ),
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: _logoScale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                    child: Image.asset('assets/icons/app_logo_dev.png', height: 60),
                  ),
                  const SizedBox(height: 16),
                  CustomText('POWERCARE',
                    style: AppTextStyles.headline3.copyWith(
                      color: Colors.white,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w900,
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

  Widget _buildBottomSheet() {
    return Positioned.fill(
      child: SlideTransition(
        position: _sheetOffset,
        child: DraggableScrollableSheet(
          initialChildSize: 0.60, minChildSize: 0.60, maxChildSize: 0.60,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
              child: Column(
                children: [
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomText('Confirm Your PIN', style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomText('Re-enter your 4-digit code to verify', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                  ),
                  const SizedBox(height: 20),
                  _buildPinDots(),
                  const Spacer(),
                  _buildKeypad(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 15.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    return AnimatedBuilder(
      animation: offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(offsetAnimation.value, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final bool isActive = pin.length > index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 16, width: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.primary : Colors.transparent,
                  border: Border.all(color: isActive ? AppColors.primary : Colors.grey.shade300, width: 1.5),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _keypadRow(["1", "2", "3"]),
        const SizedBox(height: 14),
        _keypadRow(["4", "5", "6"]),
        const SizedBox(height: 14),
        _keypadRow(["7", "8", "9"]),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 70),
            _numberKey("0"),
            IconButton(
              onPressed: () {
                if (pin.isNotEmpty) {
                  setState(() => pin = pin.substring(0, pin.length - 1));
                }
              },
              icon: Icon(Icons.backspace_outlined, color: AppColors.navyBlue.withOpacity(0.5)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _keypadRow(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: labels.map((e) => _numberKey(e)).toList(),
    );
  }

  Widget _numberKey(String label) {
    return KeypadButton( // Assuming this is defined globally or in authentication_screen.dart
      onTap: () {
        if (pin.length < 4) {
          HapticFeedback.selectionClick();
          setState(() => pin += label);
          if (pin.length == 4) verifyAndSavePin();
        }
      },
      child: CustomText(
        label,
        style: AppTextStyles.headline4.copyWith(
          color: AppColors.navyBlue,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}