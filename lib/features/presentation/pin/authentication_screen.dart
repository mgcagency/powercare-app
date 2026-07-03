import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';

import '../../../core/navigation/app_navigator.dart';
import '../../../core/storage/app_preferences.dart';
import '../dashboard/dashboard_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {
  String pin = "";
  final LocalAuthentication auth = LocalAuthentication();

  late AnimationController _animationController;
  late Animation<Offset> _sheetOffset;
  late Animation<double> _logoScale;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _sheetOffset = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.fastLinearToSlowEaseIn),
    ));

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.linear),
    ));

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricOnStart();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricOnStart() async {
    final bool canCheckBiometrics = await auth.canCheckBiometrics;
    if (canCheckBiometrics) {
      authenticateWithBiometric();
    }
  }

  Future<void> authenticateWithBiometric() async {
    try {
      // bool authenticated = await auth.authenticate(
      //   localizedReason: 'Authorize to access PowerCare Terminal',
      //   options: const AuthenticationOptions(
      //     stickyAuth: true,
      //     biometricOnly: true,
      //   ),
      // );
      // if (authenticated) {
      //   HapticFeedback.heavyImpact();
      //   AppNavigator.pushAndRemoveAll(const DashboardScreen());
      // }
    } catch (e) {
      debugPrint("Biometric Error: $e");
    }
  }

  Future<void> verifyPin() async {
    if (pin.length != 4) return;
    final savedPin = await AppPreferences.getSecretCode();

    if (savedPin == pin) {
      HapticFeedback.heavyImpact();
      AppNavigator.pushAndRemoveAll(const DashboardScreen());
    } else {
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0);
      setState(() => pin = "");
      _showToastMessage("Incorrect PIN. Try again.", isError: true);
    }
  }

  void _showToastMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText(message, style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : AppColors.navyBlue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: Stack(
        children: [
          // Branded top area — mirrors LoginScreen's hero section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.42,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset('assets/icons/login_bg.jpg', fit: BoxFit.cover),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.navyBlue.withOpacity(0.6),
                        AppColors.navyBlue,
                      ],
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
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
                          ),
                          child: Image.asset('assets/icons/app_logo_dev.png', height: 60),
                        ),
                        const SizedBox(height: 16),
                        CustomText(
                          'POWERCARE',
                          style: AppTextStyles.headline3.copyWith(
                            color: Colors.white,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        CustomText(
                          'FIELD TERMINAL LOCKED',
                          style: AppTextStyles.bodyExtraSmall.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PIN sheet — mirrors LoginScreen's DraggableScrollableSheet card
          Positioned.fill(
            child: SlideTransition(
              position: _sheetOffset,
              child: DraggableScrollableSheet(
                initialChildSize: 0.58,
                minChildSize: 0.58,
                maxChildSize: 0.58,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)],
                    ),
                    padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomText('Enter Your PIN', style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.w800)),
                          CustomText('Verify your identity to continue', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                          const SizedBox(height: 20),

                          _buildPinDots(),

                          const SizedBox(height: 20),
                          _buildKeypad(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinDots() {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 10.0)
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
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 16,
                width: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isActive ? AppColors.primary : Colors.grey.shade300,
                    width: 1.5,
                  ),
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
            _specialKey(Icons.fingerprint, authenticateWithBiometric),
            _numberKey("0"),
            _specialKey(Icons.backspace_outlined, () {
              if (pin.isNotEmpty) {
                HapticFeedback.lightImpact();
                setState(() => pin = pin.substring(0, pin.length - 1));
              }
            }),
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
    return KeypadButton(
      onTap: () {
        if (pin.length < 4) {
          HapticFeedback.selectionClick();
          setState(() => pin += label);
          if (pin.length == 4) verifyPin();
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

  Widget _specialKey(IconData icon, VoidCallback onTap) {
    return KeypadButton(
      onTap: onTap,
      filled: false,
      child: Icon(icon, size: 24, color: AppColors.navyBlue.withOpacity(0.55)),
    );
  }
}

/// A keypad key with a subtle scale-down press animation instead of a
/// default ripple.
class KeypadButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final bool filled;

  const KeypadButton({
    required this.onTap,
    required this.child,
    this.filled = true,
  });

  @override
  State<KeypadButton> createState() => KeypadButtonState();
}

class KeypadButtonState extends State<KeypadButton> {
  double _scale = 1.0;

  void _setPressed(bool pressed) {
    setState(() => _scale = pressed ? 0.92 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          height: 62,
          width: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.filled ? AppColors.primary.withValues(alpha: .01) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12)
          ),
          child: widget.child,
        ),
      ),
    );
  }
}