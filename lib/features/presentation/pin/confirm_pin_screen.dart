import 'package:flutter/material.dart';

import '../../../core/navigation/app_navigator.dart';
import '../../../core/storage/app_preferences.dart';
import '../dashboard/dashboard_screen.dart';

class ConfirmPinScreen extends StatefulWidget {
  final String firstPin;

  const ConfirmPinScreen({
    super.key,
    required this.firstPin,
  });

  @override
  State<ConfirmPinScreen> createState() =>
      _ConfirmPinScreenState();
}

class _ConfirmPinScreenState
    extends State<ConfirmPinScreen> {

  String confirmPin = "";

  void addDigit(String digit) {

    if (confirmPin.length < 4) {

      setState(() {
        confirmPin += digit;
      });

      if (confirmPin.length == 4) {
        checkPin();
      }
    }
  }

  void removeDigit() {
    if (confirmPin.isNotEmpty) {
      setState(() {
        confirmPin =
            confirmPin.substring(
                0,
                confirmPin.length - 1);
      });
    }
  }

  Future<void> checkPin() async {

    if (widget.firstPin == confirmPin) {
      print("First Pin = ${widget.firstPin}");
      print("Confirm Pin = $confirmPin");
      // TODO: Save PIN in SharedPreferences
      await AppPreferences.setSecretCode(
        confirmPin,
      );
      print(
        "After Save = ${AppPreferences.getSecretCode()}",
      );
    //  print("PIN Saved = $confirmPin");

/*      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
            (route) => false,
      );*/
      AppNavigator.pushAndRemoveAll(const DashboardScreen());

    } else {

      setState(() {
        confirmPin = "";
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "PIN does not match",
          ),
        ),
      );
    }
  }

  Widget buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index < confirmPin.length
            ? Colors.white
            : Colors.white30,
      ),
    );
  }

  Widget numberButton(String value) {

    return GestureDetector(
      onTap: () => addDigit(value),
      child: Container(
        width: 75,
        height: 75,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFFF8C00),

      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 60),

            const Icon(
              Icons.lock_outline,
              size: 90,
              color: Colors.white,
            ),

            const SizedBox(height: 20),

            const Text(
              "Confirm 4 Digit PIN",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Re-enter your PIN to confirm",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: List.generate(
                4,
                    (index) => buildDot(index),
              ),
            ),

            const SizedBox(height: 50),

            Expanded(
              child: GridView.count(
                physics:
                const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                padding: const EdgeInsets.symmetric(
                  horizontal: 70,
                ),
                children: [

                  ...List.generate(
                    9,
                        (index) =>
                        numberButton(
                          "${index + 1}",
                        ),
                  ),

                  Container(),

                  numberButton("0"),

                  GestureDetector(
                    onTap: removeDigit,
                    child: const CircleAvatar(
                      radius: 38,
                      backgroundColor:
                      Colors.white,
                      child: Icon(
                        Icons.backspace_outlined,
                        color: Colors.black,
                      ),
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
  }}