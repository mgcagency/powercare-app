import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
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
      curve: const Interval(0.0, 0.5, curve: Curves.linear),
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
                            label: 'Corporate Email',
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 25),
                          _buildModernInput(
                            controller: _passwordController,
                            label: 'Security Pin/Password',
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
        TextField(
          controller: controller,
          obscureText: obscure,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.navyBlue, size: 22),
            suffixIcon: isPassword ? IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: onToggle) : null,
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _performLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.5),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText('AUTHORIZE ACCESS', style: AppTextStyles.button.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.w900)),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}
/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart'; // Corrected import
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/core/storage/secure_storage.dart';
import 'package:powercare_flutter/features/alldata/api_repository/auth_repository.dart';
import 'package:powercare_flutter/features/presentation/dashboard/dashboard_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/storage/app_preferences.dart';
import '../../alldata/models/login_response.dart';
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
  bool _isLoadingid = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeSlideAnimation;
  final AuthRepository _repository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _loadStoredCredentials();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeSlideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();

    // Default values for testing
    _emailController.text = "powercareelectrical@icloud.com";
    _passwordController.text = "Password@123";
    _setupTokenRefresh();
  }

  void _setupTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final isLoggedIn = await AppPreferences.isLoggedIn();
      if (isLoggedIn) {
        try {
          await SecureStorage.saveToken(newToken);
          debugPrint("FCM Token updated successfully on refresh");
        } catch (e) {
          debugPrint("Failed to update FCM Token on refresh: $e");
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadStoredCredentials() async {
    setState(() {
      _rememberMe = false;
    });
  }

  void _showToastMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: CustomText(message, style: AppTextStyles.bodySmall.copyWith(color: Colors.white))),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.textColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _performLogin() async {

    if (_emailController.text.isEmpty) {
      _showToastMessage("Please enter valid email", isError: true);
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showToastMessage("Please enter correct password", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var fcmToken = await FirebaseMessaging.instance.getToken();
    fcmToken ??= await SecureStorage.getToken();

    try {
      var payload = {
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
        "deviceId": "123456",
        "fcmToken": fcmToken,
      };

      final loginResponse = await _repository.login(payload);

      if (loginResponse.statusCode == 200 || loginResponse.statusCode == 201) {
        final user = loginResponse.data;

        if (user != null) {
          if (loginResponse.token != null) {
            await SecureStorage.saveToken(loginResponse.token!);
          }

          final Map<String, dynamic> userMap = {
            'id': user.id,
            'firstName': user.firstName,
            'lastName': user.lastName,
            'email': user.email,
            'role': user.role,
            'user_image': user.userImage,
            'contact_number': user.contactNumber,
            'status': user.status,
            'accessToken': user.accessToken,
          };

          await AppPreferences.saveUser(userMap);
          await AppPreferences.setLoggedIn(true);
          await AppPreferences.saveRole(user.role ?? "ENGINEER");
          await AppPreferences.saveUserImage(user.userImage ?? "");
          await AppPreferences.saveUserName("${user.firstName} ${user.lastName}");
          await AppPreferences.saveUserEmail(user.email ?? "");
          await AppPreferences.saveUserId(user.id.toString());

          _showToastMessage(loginResponse.message ?? "Login Success");
          if (user.secretCode == null ||
              user.secretCode == 0) {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const CreatePinScreen(),
              ),
            );

          } else {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AuthenticationScreen(),
              ),
            );
          }
  */
/*        if (user.secretCode != null && user.secretCode! > 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CreatePinScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AuthenticationScreen()),
            );
          }*//*

        }
      } else {
        _showToastMessage(loginResponse.message ?? "Login Failed", isError: true);
      }
    } catch (e) {
      _showToastMessage("Error: ${e.toString()}", isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/icons/login_bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: FadeTransition(
                  opacity: _fadeSlideAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(_fadeSlideAnimation),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _buildLoginCard(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(56),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          children: [
            _buildBrand(),
            const SizedBox(height: 32),
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildOptionsRow(),
            const SizedBox(height: 26),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Image.asset(
          'assets/icons/app_logo_dev.png',
          width: 70,
          height: 70,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        CustomText(
          'PowerCare',
          style: AppTextStyles.headline3.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        CustomText(
          'electrical services limited',
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF5A6874),
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Email address',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF9AA6B5), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade500),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9AA6B5), size: 20),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9AA6B5), size: 20),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (bool? value) => setState(() => _rememberMe = value ?? false),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            CustomText('Remember me', style: AppTextStyles.bodySmall),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
          child: CustomText(
            'Forgot password?',
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildGradientButton(
          onPressed: _isLoading ? null : _performLogin,
          isLoading: _isLoading,
          text: 'Login',
          icon: Icons.arrow_forward,
          colors: [const Color(0xFFFF8A00), const Color(0xFFFF6B00)],
        ),
        const SizedBox(height: 20),
        _buildGradientButton(
          onPressed: () {}, // Handle biometric logic
          isLoading: _isLoadingid,
          text: 'Login with Face ID',
          icon: Icons.fingerprint,
          colors: [const Color(0xFF0F2D52), const Color(0xFF1D4E89)],
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required String text,
    required IconData icon,
    required List<Color> colors,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors, begin: Alignment.centerLeft, end: Alignment.centerRight),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                else ...[
                  CustomText(text, style: AppTextStyles.button.copyWith(color: Colors.white)),
                  const SizedBox(width: 12),
                  Icon(icon, color: Colors.white, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/
