import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/navigation/app_navigator.dart';
import '../../../core/storage/app_preferences.dart';
import '../dashboard/dashboard_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() =>
      _AuthenticationScreenState();
}

class _AuthenticationScreenState
    extends State<AuthenticationScreen> {

  String pin = "";

  final LocalAuthentication auth =
  LocalAuthentication();

  Future<void> authenticateWithBiometric() async {

    try {

      bool authenticated =
      await auth.authenticate(
        localizedReason:
        'Authenticate to login PowerCare',
      );

      if (authenticated) {

        AppNavigator.pushAndRemoveAll(const DashboardScreen());

      }

    } catch (e) {


      debugPrint(
        "Biometric Error: $e",
      );
    }
  }

  Future<void> verifyPin() async {

    if (pin.length != 4) return;
    print("Entered Pin = $pin");
    final savedPin =
    await AppPreferences.getSecretCode();
    print("Saved Pin = ${AppPreferences.getSecretCode()}");

    if (savedPin == pin) {

      AppNavigator.pushAndRemoveAll(const DashboardScreen());


    } else {

      setState(() {
        pin = "";
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Invalid PIN",
          ),
        ),
      );
    }
  }
  Widget numberButton(String value) {
    return GestureDetector(
      onTap: () {
        if (pin.length < 4) {
          setState(() {
            pin += value;
          });

          if (pin.length == 4) {
            verifyPin();
          }
        }
      },
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.cyanAccent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // backgroundColor: const Color(0xFFFF8A00),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/icons/login_bg.jpg",
            ),
            fit: BoxFit.cover,
            opacity: 0.90,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              const SizedBox(height: 60),

              const Icon(
                Icons.lock_outline,
                size: 70,
                color: Colors.white,
              ),

              const SizedBox(height: 20),
              const Text(
                "Enter Your PIN",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                "Enter your 4-digit PIN to continue",
                style: TextStyle(
                  color: Colors.white70,
                 // fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pin.length > index
                          ? Colors.white
                          : Colors.transparent,
                      border: Border.all(
                        color: Colors.white70,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
/*              const SizedBox(height: 20),

              TextButton(
                onPressed: () {},
                child: const Text(
                  "Forgot PIN?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              IconButton(
                onPressed: authenticateWithBiometric,
                icon: const Icon(
                  Icons.fingerprint,
                  color: Colors.white,
                  size: 45,
                ),
              ),*/
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: [
                      for (int i = 1; i <= 9; i++)
                        numberButton("$i"),

                      Container(),

                      numberButton("0"),

                      GestureDetector(
                        onTap: () {
                          if (pin.isNotEmpty) {
                            setState(() {
                              pin = pin.substring(
                                0,
                                pin.length - 1,
                              );
                            });
                          }
                        },
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.cyanAccent,
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.backspace_outlined,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}