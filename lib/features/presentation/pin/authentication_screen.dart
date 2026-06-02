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

  void verifyPin() {

    if (pin.length != 4) return;
    print("Entered Pin = $pin");
    final savedPin =
    AppPreferences.getSecretCode();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF8A00),
      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 30),

            const Icon(
              Icons.lock_outline,
              size: 90,
              color: Colors.white,
            ),

            const SizedBox(height: 20),

            const Text(
              "Enter your 4-digit password",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                    (index) => Container(
                  margin: const EdgeInsets.all(8),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < pin.length
                        ? Colors.white
                        : Colors.white30,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {},
              child: const Text(
                "Forgot PIN?",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [

                  for (int i = 1; i <= 9; i++)
                    ElevatedButton(
                      onPressed: () {
                        if (pin.length < 4) {
                          setState(() {
                            pin += i.toString();
                          });

                          if (pin.length == 4) {
                            verifyPin();
                          }
                        }
                      },
                      child: Text(
                        "$i",
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),

                  const SizedBox(),

                  ElevatedButton(
                    onPressed: () {
                      if (pin.length < 4) {
                        setState(() {
                          pin += "0";
                        });

                        if (pin.length == 4) {
                          verifyPin();
                        }
                      }
                    },
                    child: const Text(
                      "0",
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      if (pin.isNotEmpty) {
                        setState(() {
                          pin = pin.substring(
                            0,
                            pin.length - 1,
                          );
                        });
                      }
                    },
                    child: const Icon(
                      Icons.backspace,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}