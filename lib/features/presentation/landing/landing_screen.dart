import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/app/widget/custom_textfield.dart';
import 'package:powercare_flutter/core/services/notification_service.dart';
import 'package:powercare_flutter/core/storage/secure_storage.dart';
import 'package:powercare_flutter/features/alldata/api_repository/auth_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/storage/app_preferences.dart';
import '../pin/authentication_screen.dart';
import '../pin/create_pin_screen.dart';
import 'forgotpassword_Screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<Offset> _sheetOffset;
  late Animation<double> _logoScale;
  final AuthRepository _repository = AuthRepository();

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
      curve: const Interval(0.0, 0.5, curve: Curves.easeInToLinear),
    ));

    _animationController.forward();
    _emailController.text = "powercareelectrical@icloud.com";
    _passwordController.text = "Password@123";
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
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

  Future<void> _performLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showToastMessage("Required fields missing", isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      var fcmToken = await NotificationService().getToken() ?? await SecureStorage.getToken();
      var payload = {
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
        "deviceId": "123456",
        "fcmToken": fcmToken,
      };
      final loginResponse = await _repository.login(payload);
      if (loginResponse.statusCode == 200 || loginResponse.statusCode == 201) {
        final user = loginResponse.data!;
        if (loginResponse.token != null) await SecureStorage.saveToken(loginResponse.token!);
        await AppPreferences.saveUser({
          'id': user.id,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'email': user.email,
          'role': user.role,
          'accessToken': user.accessToken,
        });
        await AppPreferences.setLoggedIn(true);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>
        user.secretCode != null && user.secretCode! > 0 ? const CreatePinScreen() : const AuthenticationScreen()));
      } else {
        _showToastMessage(loginResponse.message ?? "Authentication Failed", isError: true);
      }
    } catch (e) {
      _showToastMessage("Connection Error", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: Stack(
        children: [
          // Background Branded Area
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset('assets/icons/login_bg.jpg', fit: BoxFit.cover),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
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
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
                          ),
                          child: Image.asset('assets/icons/app_logo_dev.png', height: 60),
                        ),
                        const SizedBox(height: 16),
                        CustomText('POWERCARE', style: AppTextStyles.headline3.copyWith(color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.w900)),
                        CustomText('ENGINEERING SOLUTIONS', style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.primary, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Login Sheet
          Positioned.fill(
            child: SlideTransition(
              position: _sheetOffset,
              child: DraggableScrollableSheet(
                initialChildSize: 0.6,
                minChildSize: 0.6,
                maxChildSize: 0.95,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40, height: 4,
                              margin: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomText('Engineer Login', style: AppTextStyles.headline4.copyWith(fontWeight: FontWeight.w800)),
                          CustomText('Access your field terminal', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                          const SizedBox(height: 35),

                          _buildModernInput(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 25),
                          _buildModernInput(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.key_outlined,
                            isPassword: true,
                            obscure: _obscurePassword,
                            onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Switch.adaptive(
                                    value: _rememberMe,
                                    activeColor: AppColors.primary,
                                    onChanged: (v) => setState(() => _rememberMe = v),
                                  ),
                                  CustomText('Stay logged in', style: AppTextStyles.bodySmall),
                                ],
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                                child: CustomText('Forgot Pin?', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          _buildSubmitButton(),
                          const SizedBox(height: 40),
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

  Widget _buildModernInput({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false, bool obscure = false, VoidCallback? onToggle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(label.toUpperCase(), style: AppTextStyles.bodyExtraSmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1)),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          obscureText: obscure,
          prefixIcon: Icon(icon, color: AppColors.navyBlue, size: 22),
          // style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          // decoration: InputDecoration(
          //   prefixIcon: Icon(icon, color: AppColors.navyBlue, size: 22),
          //   suffixIcon: isPassword ? IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: onToggle) : null,
          //   enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5)),
          //   focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
          //   contentPadding: const EdgeInsets.symmetric(vertical: 15),
          // ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _performLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.5),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText('AUTHORIZE ACCESS', style: AppTextStyles.button.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}