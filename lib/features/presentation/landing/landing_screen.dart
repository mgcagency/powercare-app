import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
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
    // Simulating loading from secure storage
    // In real app, use flutter_secure_storage or shared_preferences
    setState(() {
      _rememberMe = false;
      _emailController.text = '';
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
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? Colors.red.shade700
            : const Color(0xFF1E293B),
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
        "deviceId": "123456", // Ideally get real device ID
        "fcmToken": fcmToken,
      };

      final loginResponse = await _repository.login(payload);

      if (loginResponse.statusCode == 200 || loginResponse.statusCode == 201) {
        final user = loginResponse.data;

        if (user != null) {
          // 1. Save the main Token to Secure Storage
          if (loginResponse.token != null) {
            await SecureStorage.saveToken(loginResponse.token!);
          }

          // 2. Prepare user map for AppPreferences
          // We manually create a map to ensure keys match what your app expects
          final Map<String, dynamic> userMap = {
            'id': user.id,
            'firstName': user.firstName,
            'lastName': user.lastName,
            'email': user.email,
            'role': user.role,
            'user_image': user.userImage,
            'contact_number': user.contactNumber,
            'status': user.status,
            'accessToken': user.accessToken, // Token inside the data object
          };

          // 3. Store data in AppPreferences
          await AppPreferences.saveUser(userMap);
          await AppPreferences.setLoggedIn(true);
          await AppPreferences.saveRole(user.role ?? "ENGINEER");
          await AppPreferences.saveUserImage(user.userImage ?? "");
          await AppPreferences.saveUserName("${user.firstName} ${user.lastName}");
          await AppPreferences.saveUserEmail(user.email ?? "");
          await AppPreferences.saveUserId(user.id.toString());

          _showToastMessage(loginResponse.message ?? "Login Success");

          // 4. Navigation Logic based on secretCode
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
  void _handleSocialLogin(String provider) {
    _showToastMessage('$provider Sign-In — coming in the next update 🚀');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/icons/login_bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
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
        // color: Colors.white.withOpacity(0.92),
        color: Colors.white,
        borderRadius: BorderRadius.circular(56),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(56),
        child: Material(
          color: Colors.transparent,
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
                buildLoginButton(),
                const SizedBox(height: 26),
                buildLoginFaceButton(),
                /*  const SizedBox(height: 28),
                _buildDivider(),
                const SizedBox(height: 28),
                _buildSignupPrompt(),*/
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            /*      gradient: const LinearGradient(
              colors: [
                Color(0xFF0F2D52),
                Color(0xFF1D4E89),
                Color(0xFFFF6B00),
              ],
            ),*/
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              /*    BoxShadow(
                color: const Color(0xFFFF6B6B).withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 15),
              ),*/
            ],
          ),
          child: Image.asset(
            'assets/icons/app_logo_dev.png',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
          ).createShader(bounds),
          child: const Text(
            'PowerCare',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'electrical services limited',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5A6874),
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Email address',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: Color(0xFF9AA6B5),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9AA6B5)),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
  /*  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9AA6B5), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }*/

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (bool? value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: const Color(0xFFFF6B6B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Remember me',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            );
          },
          /*   onTap: () {
            String email = _emailController.text.trim();
            if (email.isNotEmpty && email.contains('@')) {
              _showToastMessage('Reset link sent to $email ✉️');
            } else {
              _showToastMessage('Enter your email address first to reset password', isError: true);
            }
          },*/
          child: const Text(
            'Forgot password?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF6B6B),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _performLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF8A00),
                Color(0xFFFF6B00),

                /*    Color(0xFFFF6B00), // Navy Blue
                Color(0xFFFF6B00), // Blue
                Color(0xFFFF6B00), // Orange*/
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2D52).withOpacity(0.35),
                blurRadius: 0,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else ...[
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLoginFaceButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoadingid ? null : _LoginScreenState.new,
        //_performLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F2D52),
                Color(0xFF1D4E89),
                /*      Color(0xFFFF6B00), // Navy Blue
                Color(0xFFFF6B00), // Blue
                Color(0xFFFF6B00), // Orange*/
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2D52).withOpacity(0.35),
                blurRadius: 0,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoadingid)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else ...[
                  const Text(
                    'Login with Face ID',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  Icon(Icons.fingerprint, color: Colors.white, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  /*
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.black.withOpacity(0.1))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or continue with',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFA0ABB9)),
          ),
        ),
        Expanded(child: Container(height: 1, color: Colors.black.withOpacity(0.1))),
      ],
    );
  }*/

  /*  Widget _buildSignupPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Don\'t have an account?',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF4B5565)),
        ),
        GestureDetector(
          onTap: () {
            _showToastMessage('Create your Power care account — get started');
          },
          child: const Text(
            ' Create Account',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFF6B6B),
            ),
          ),
        ),
      ],
    );
  }*/
}
