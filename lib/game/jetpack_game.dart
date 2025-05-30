import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'dart:math';
import '../controller/game_controller.dart';

class JetpackGame extends FlameGame with TapDetector, HasCollisionDetection {
  late SpriteComponent background1;
  late SpriteComponent background2;
  late Player player;
  late Timer coinTimer;
  late Timer enemyTimer;
  final GameController controller;
  final double backgroundSpeed = 100; // pixels per second
  Random rng = Random();

  bool prologueShown = false;
  bool prologueEndingShown = false;

  JetpackGame(this.controller);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await loadInitialAssets();
  }

  Future<void> loadInitialAssets() async {
    final bgSprite = await loadSprite('background.png');
    background1 = SpriteComponent()
      ..sprite = bgSprite
      ..size = size
      ..position = Vector2(0, 0);
    background2 = SpriteComponent()
      ..sprite = bgSprite
      ..size = size
      ..position = Vector2(size.x, 0);
    add(background1);
    add(background2);

    final playerSprite = await loadSprite('player.png');
    player = Player(sprite: playerSprite);
    await add(player);

    coinTimer = Timer(1.5, repeat: true, onTick: spawnCoin)..start();
    enemyTimer = Timer(3, repeat: true, onTick: spawnEnemy)..start();

    final upSprite = await loadSprite('arrow_up.png');
    add(
      HudButtonComponent(
        button: SpriteComponent(sprite: upSprite, size: Vector2(48, 48)),
        margin: const EdgeInsets.only(left: 20, bottom: 40),
        anchor: Anchor.bottomLeft,
        onPressed: () {
          player.isThrusting = true;
        },
        onReleased: () {
          player.isThrusting = false;
        },
        position: Vector2(20, size.y - 60),
      )..priority = 100,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    coinTimer.update(dt);
    enemyTimer.update(dt);
    checkCollisions();

    background1.x -= backgroundSpeed * dt;
    background2.x -= backgroundSpeed * dt;

    if (background1.x <= -size.x) {
      background1.x = background2.x + size.x;
    }
    if (background2.x <= -size.x) {
      background2.x = background1.x + size.x;
    }
  }

  void spawnCoin() async {
    final coinSprite = await loadSprite('coin.png');
    final coin = Coin(sprite: coinSprite)
      ..size = Vector2(30, 30)
      ..position = Vector2(size.x, rng.nextDouble() * (size.y - 30));
    add(coin);
    coin.add(
      MoveEffect.to(
        Vector2(-30, coin.y),
        EffectController(duration: 4),
        onComplete: () => coin.removeFromParent(),
      ),
    );
  }

  void spawnEnemy() async {
    final enemySprite = await loadSprite('robot.png');
    final enemy = EnemyRobot(sprite: enemySprite)
      ..size = Vector2(100, 100)
      ..position = Vector2(size.x, rng.nextDouble() * (size.y - 60));
    add(enemy);
    enemy.add(
      MoveEffect.to(
        Vector2(-60, enemy.y),
        EffectController(duration: 3),
        onComplete: () => enemy.removeFromParent(),
      ),
    );
  }

  void checkCollisions() {
    children.whereType<Coin>().toList().forEach((coin) {
      if (player.toRect().overlaps(coin.toRect())) {
        controller.addScore(1);

        if (controller.score == 10 && !prologueShown) {
          pauseEngine();
          overlays.add('PrologueOverlay');
          prologueShown = true;
          changeAssets();
        } else if (controller.score == 20 && !prologueEndingShown) {
          pauseEngine();
          overlays.add('PrologueOverlayEnding');
          prologueEndingShown = true;
          changeAssets2();
        }

        coin.removeFromParent();
      }
    });

    children.whereType<EnemyRobot>().toList().forEach((enemy) {
      if (player.toRect().overlaps(enemy.toRect())) {
        controller.addScore(-1);
        enemy.removeFromParent();
      }
    });
  }

  Future<void> onPrologueFinished() async {
    overlays.remove('PrologueOverlay');
    await changeAssets();
    resumeEngine();
  }

  Future<void> changeAssets() async {
    final newBgSprite = await loadSprite('background_2.png');
    final newPlayerSprite = await loadSprite('player_2.png');

    background1.sprite = newBgSprite;
    background2.sprite = newBgSprite;
    player.sprite = newPlayerSprite;
  }

  Future<void> changeAssets2() async {
    final newBgSprite = await loadSprite('background_3.jpg');
    final newPlayerSprite = await loadSprite('player_3.png');

    background1.sprite = newBgSprite;
    background2.sprite = newBgSprite;
    player.sprite = newPlayerSprite;
  }

  @override
  void onTapDown(TapDownInfo info) {
    player.isThrusting = true;
  }

  @override
  void onTapUp(TapUpInfo info) {
    player.isThrusting = false;
  }

  void reset() {
    children.whereType<SpriteComponent>().forEach((c) {
      if (c != background1 && c != background2 && c != player) {
        c.removeFromParent();
      }
    });
    player.position = Vector2(50, size.y / 2);
    player.velocity = Vector2.zero();
  }
}

class Player extends SpriteComponent with HasGameRef<JetpackGame> {
  bool isThrusting = false;
  Vector2 velocity = Vector2.zero();
  final Vector2 gravity = Vector2(0, 600);
  final Vector2 thrust = Vector2(0, -800);

  Player({super.sprite}) {
    size = Vector2(100, 100);
  }

  bool isInitialized = false;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    if (!isInitialized) {
      position = Vector2(50, gameSize.y / 2);
      isInitialized = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    velocity += gravity * dt;

    if (isThrusting) {
      velocity += thrust * dt;
    }

    position += velocity * dt;

    final screenHeight = gameRef.size.y;
    final playerHeight = size.y;

    if (position.y < 0) {
      position.y = 0;
      velocity.y = 0;
    } else if (position.y > screenHeight - playerHeight) {
      position.y = screenHeight - playerHeight;
      velocity.y = 0;
    }
  }
}

class Coin extends SpriteComponent {
  Coin({super.sprite});
}

class EnemyRobot extends SpriteComponent {
  EnemyRobot({super.sprite});
}
