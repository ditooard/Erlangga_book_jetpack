import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:jetpack_joy/controller/game_controller.dart';
import 'package:jetpack_joy/game/jetpack_game.dart';
import 'package:jetpack_joy/screen/epilogue_scene.dart';
import 'package:jetpack_joy/screen/overlay.dart';
import 'package:jetpack_joy/screen/overlay_ending.dart'; // Pastikan file ini ada

class GameScreen extends StatelessWidget {
  final JetpackGame game;
  final GameController controller;

  const GameScreen({super.key, required this.game, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'PrologueOverlay': (context, _) => PrologueOverlay(
                    onDone: () {
                      game.overlays.remove('PrologueOverlay');
                      game.resumeEngine();
                    },
                  ),
              'PrologueOverlayEnding': (context, _) => PrologueOverlayEnding(
                    onDone: () {
                      game.overlays.remove('PrologueOverlayEnding');
                      game.resumeEngine();
                    },
                  ),
              'EpilogueOverlay': (context, _) => EpilogueScreen(),
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, __) => Text(
                'Buku  : ${controller.score}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, __) => IconButton(
                icon: Icon(
                  controller.isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                ),
                onPressed: () {
                  controller.togglePause();
                  if (controller.isPaused) {
                    game.pauseEngine();
                  } else {
                    game.resumeEngine();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
