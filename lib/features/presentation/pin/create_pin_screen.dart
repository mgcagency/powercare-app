import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'authentication_screen.dart';
import 'confirm_pin_screen.dart'; // Import your confirm screen

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> with TickerProviderStateMixin {
  String pin = "";
  late AnimationController _animationController;
  late Animation<Offset> _sheetOffset;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _sheetOffset = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 1.0, curve: Curves.fastLinearToSlowEaseIn)),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.linear)),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void onPinComplete() {
    if (pin.length == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ConfirmPinScreen(originalPin: pin)),
      );
      // Optional: Clear PIN so if they come back it's empty
      Future.delayed(const Duration(milliseconds: 500), () => setState(() => pin = ""));
    }
  }

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
          Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.navyBlue.withOpacity(0.6), AppColors.navyBlue]))),
          Center(
            child: ScaleTransition(
              scale: _logoScale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: Image.asset('assets/icons/app_logo_dev.png', height: 60)),
                  const SizedBox(height: 16),
                  CustomText('POWERCARE', style: AppTextStyles.headline3.copyWith(color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.w900)),
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
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
              child: Column(
                children: [
                  Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerLeft, child: CustomText('Create Your PIN', style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.w800))),
                  Align(alignment: Alignment.centerLeft, child: CustomText('Set a 4-digit code to secure your terminal', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey))),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final bool isActive = pin.length > index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          height: 16, width: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? AppColors.primary : Colors.transparent, border: Border.all(color: isActive ? AppColors.primary : Colors.grey.shade300, width: 1.5)),
        );
      }),
    );
  }
  Widget _keypadRow(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: labels.map((e) => _numberKey(e)).toList(),
    );
  }

  Widget _numberKey(String label) {
    return KeypadButton(
      onTap: () {
        if (pin.length < 4) {
          HapticFeedback.selectionClick();
          setState(() => pin += label);
          if (pin.length == 4) onPinComplete();
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
            const SizedBox(width: 70), // Spacer for fingerprint spot
            _numberKey("0"),
            IconButton(onPressed: () => setState(() => pin = pin.isNotEmpty ? pin.substring(0, pin.length - 1) : ""), icon: Icon(Icons.backspace_outlined, color: AppColors.navyBlue.withOpacity(0.5))),
          ],
        ),
      ],
    );
  }


}