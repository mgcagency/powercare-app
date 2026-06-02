import 'package:flutter/material.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {

  String pin = "";

  void addDigit(String digit) {


    if (pin.length < 4) {

    setState(() {
    pin += digit;
    });

    if (pin.length == 4) {

    Future.delayed(
    const Duration(milliseconds: 200),
    () {
/*
    Navigator.push(
    context,
*//*    MaterialPageRoute(
    builder: (_) => ConfirmPinScreen(
    firstPin: pin,
    ),
    ),*//*
    );*/

    },
    );
    }
    }


  }

  void removeDigit() {
    if (pin.isNotEmpty) {
      setState(() {
        pin = pin.substring(
          0,
          pin.length - 1,
        );
      });
    }
  }

  Widget buildPinCircle(int index) {


    return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8),
    width: 18,
    height: 18,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: index < pin.length
    ? Colors.white
        : Colors.white30,
    ),
    );


  }

  Widget buildNumberButton(String value) {


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
    ),
    ),
    ),
    ),
    );


  }

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
    "Create 4 Digit PIN",
    style: TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    ),
    ),

    const SizedBox(height: 10),

    const Text(
    "Create a secure PIN for quick login",
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
    (index) =>
    buildPinCircle(index),
    ),
    ),

    const Spacer(),

    GridView.count(
    shrinkWrap: true,
    crossAxisCount: 3,
    mainAxisSpacing: 20,
    crossAxisSpacing: 20,
    padding:
    const EdgeInsets.symmetric(
    horizontal: 70,
    ),
    children: [

    ...List.generate(
    9,
    (index) =>
    buildNumberButton(
    "${index + 1}",
    ),
    ),

    Container(),

    buildNumberButton("0"),

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

    const SizedBox(height: 40),
    ],
    ),
    ),
    );

  }
}
