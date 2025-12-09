import 'package:flutter/material.dart';
import 'package:jetpack_joy/screen/landing_screen.dart';

class EpilogueScreen extends StatefulWidget {
  const EpilogueScreen({super.key});

  @override
  State<EpilogueScreen> createState() => _EpilogueScreenState();
}

class _EpilogueScreenState extends State<EpilogueScreen> {
  final List<String> prologues = [
    'assets/images/epilogue1.png',
    'assets/images/epilogue2.png',
    'assets/images/epilogue3.png',
  ];

  int currentIndex = 0;

  void nextPage() {
    if (currentIndex < prologues.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LandingPage(),
        
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: nextPage,
      child: Scaffold(
        body: SizedBox.expand(
          child: Image.asset(
            prologues[currentIndex],
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
    );
  }
}
