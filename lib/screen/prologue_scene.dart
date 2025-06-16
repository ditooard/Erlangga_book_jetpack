import 'package:flutter/material.dart';
import 'package:jetpack_joy/controller/game_controller.dart';
import 'package:jetpack_joy/screen/game_screen.dart';
import 'package:jetpack_joy/game/jetpack_game.dart';

class PrologueScreen extends StatefulWidget {
  const PrologueScreen({super.key});

  @override
  State<PrologueScreen> createState() => _PrologueScreenState();
}

class _PrologueScreenState extends State<PrologueScreen> {
  final List<String> prologues = [
    'assets/images/prologue1.png',
    'assets/images/prologue2.png',
    'assets/images/prologue3.png',
  ];

  int currentIndex = 0;

  void nextPage() {
    if (currentIndex < prologues.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      final controller = GameController();
      final game = JetpackGame(controller);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(game: game, controller: controller),
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
