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

          if (user.secretCode != null && user.secretCode! > 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CreatePinScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AuthenticationScreen()),
            );
          }
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
}