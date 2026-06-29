import 'package:flutter/material.dart';

import 'confirm_pin_screen.dart';

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

      print("Create PIN = $pin");
    Future.delayed(
    const Duration(milliseconds: 200),
    () {
      print("Opening Confirm Screen");

    Navigator.push(
    context,
   MaterialPageRoute(
    builder: (_) => ConfirmPinScreen(
    firstPin: pin,
    ),
    ),
    );

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

/*  Widget buildPinCircle(int index) {


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


  }*/

/*  Widget buildNumberButton(String value) {


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


  }*/
  Widget buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => addDigit(number),
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
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
  Widget buildPinCircle(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
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
    );
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
   // backgroundColor: const Color(0xFFFF8C00),

    body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
      image: AssetImage('assets/icons/login_bg.jpg'),
      fit: BoxFit.cover,opacity:0.90,
      ),
  /*    gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2C5364),
          Color(0xFF203A43),
          Color(0xFF0F2027),
        ],
      ),*/
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
      "Create PIN",
      style: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      ),
      ),

      const SizedBox(height: 10),

      const Text(
      "Create a PIN to securely access your account",
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
        const SizedBox(height: 40),

     // const Spacer(),

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
                size: 35,
              ),
            ),
          ),
        ),
/*      GestureDetector(
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
      ),*/
      ],
      ),

      const SizedBox(height: 40),
      ],
      ),
      ),
    ),
    );

  }
}
