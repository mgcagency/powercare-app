import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final TextEditingController _emailController =
  TextEditingController();

  bool _isLoading = false;

  void _sendResetLink() async {

    if (_emailController.text.trim().isEmpty) {
      _showMessage(
        "Please enter your email address",
        true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(
      const Duration(seconds: 2),
    );

    setState(() {
      _isLoading = false;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),
          title: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 60,
          ),
          content: const Text(
            "Password reset link has been sent to your email.",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(
      String message,
      bool isError,
      ) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError
            ? Colors.red
            : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "assets/icons/login_bg.jpg",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Container(
                  padding:
                  const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      40,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.1),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [

                      Image.asset(
                        "assets/icons/app_logo_dev.png",
                        height: 80,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      const Text(
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const Text(
                        "Enter your registered email address to receive a password reset link.",
                        textAlign:
                        TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      TextField(
                        controller:
                        _emailController,
                        decoration:
                        InputDecoration(
                          hintText:
                          "Email Address",
                          prefixIcon:
                          const Icon(
                            Icons.email,
                          ),
                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                                30),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      SizedBox(
                        width:
                        double.infinity,
                        height: 55,
                        child:
                        ElevatedButton(
                          onPressed:
                          _isLoading
                              ? null
                              : _sendResetLink,
                          style:
                          ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            const Color(
                                0xFFFF6B00),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                  40),
                            ),
                          ),
                          child:
                          _isLoading
                              ? const CircularProgressIndicator(
                            color:
                            Colors
                                .white,
                          )
                              : const Text(
                            "Send Reset Link",
                            style:
                            TextStyle(
                              color:
                              Colors
                                  .white,
                              fontSize:
                              16,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(
                              context);
                        },
                        icon: const Icon(
                          Icons
                              .arrow_back,size: 30,
                        ),
                        label: const Text(
                          "Back To Login",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}