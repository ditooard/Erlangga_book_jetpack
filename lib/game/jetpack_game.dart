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

  // Untuk Gun item & bullets
  bool hasGun = false;
  late Timer gunTimer;
  late Timer bulletTimer;
  late Sprite bulletSprite;
  late Sprite gunItemSprite;

  final GameController controller;
  final double backgroundSpeed = 100;
  Random rng = Random();

  bool prologueShown = false;
  bool prologueEndingShown = false;

  // Untuk Boss
  bool bossSpawned = false;
  BossRobot? boss;

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
    enemyTimer = Timer(enemySpawnInterval, repeat: true, onTick: spawnEnemy)
      ..start();

    // preload sprites for bullets and gun item
    bulletSprite = await loadSprite('bullet.png');
    gunItemSprite = await loadSprite('gun_item.png');

    // spawn rare shooting item setiap 15 detik
    gunTimer = Timer(15, repeat: true, onTick: spawnGunItem)..start();
    // siapkan timer untuk tembakan otomatis (0.5s interval), tapi start hanya setelah ambil item
    bulletTimer = Timer(0.5, repeat: true, onTick: spawnBullet);

    // HUD button (sudah ada)
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

  double get enemySpeed {
    if (controller.score >= 150) return 400;
    if (controller.score >= 100) return 300;
    if (controller.score >= 50) return 200;
    return 120;
  }

  double get enemySpawnInterval {
    if (controller.score >= 150) return 0.7;
    if (controller.score >= 100) return 1.2;
    if (controller.score >= 50) return 2.0;
    return 3.0;
  }

  int get enemySpawnCount => 1;

  @override
  void update(double dt) {
    super.update(dt);

    // Update timers
    if (!enemyTimer.isRunning() || enemyTimer.limit != enemySpawnInterval) {
      enemyTimer.stop();
      enemyTimer = Timer(enemySpawnInterval, repeat: true, onTick: spawnEnemy)
        ..start();
    }
    coinTimer.update(dt);
    enemyTimer.update(dt);
    gunTimer.update(dt);
    bulletTimer.update(dt);

    checkCollisions();

    // Scroll background
    background1.x -= backgroundSpeed * dt;
    background2.x -= backgroundSpeed * dt;
    if (background1.x <= -size.x) {
      background1.x = background2.x + size.x;
    }
    if (background2.x <= -size.x) {
      background2.x = background1.x + size.x;
    }

    // Boss logic based on score
    if (controller.score >= 100 && !bossSpawned) {
      spawnBoss();
      bossSpawned = true;
    }
  }

  // Spawn coin
  void spawnCoin() async {
    final coinSprite = await loadSprite('coin.png');
    final coin = Coin(sprite: coinSprite)
      ..size = Vector2(50, 50)
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

  // Spawn enemy
  void spawnEnemy() async {
    for (int i = 0; i < enemySpawnCount; i++) {
      final enemySprite = await loadSprite('robot.png');
      final enemy = EnemyRobot(sprite: enemySprite)
        ..size = Vector2(200, 200)
        ..position = Vector2(size.x, rng.nextDouble() * (size.y - 60));
      add(enemy);
      enemy.add(
        MoveEffect.to(
          Vector2(-60, enemy.y),
          EffectController(duration: size.x / enemySpeed),
          onComplete: () => enemy.removeFromParent(),
        ),
      );
    }
  }

  // Spawn the rare gun item
  void spawnGunItem() {
    final item = GunItem(sprite: gunItemSprite)
      ..size = Vector2(50, 50)
      ..position = Vector2(size.x, rng.nextDouble() * (size.y - 50));
    add(item);
    item.add(
      MoveEffect.to(
        Vector2(-50, item.y),
        EffectController(duration: 6),
        onComplete: () => item.removeFromParent(),
      ),
    );
  }

  // Spawn a bullet if player has gun
  void spawnBullet() {
    if (!hasGun) return;
    final bullet = Bullet(sprite: bulletSprite);
    add(bullet);
  }

  // Collision handling
  void checkCollisions() {
    // GunItem pickup
    children.whereType<GunItem>().toList().forEach((item) {
      if (player.toRect().overlaps(item.toRect())) {
        hasGun = true;
        bulletTimer.start();
        item.removeFromParent();
      }
    });

    // Bullets vs EnemyRobot
    children.whereType<Bullet>().toList().forEach((bullet) {
      // check against each enemy
      children.whereType<EnemyRobot>().toList().forEach((enemy) {
        if (bullet.toRect().overlaps(enemy.toRect())) {
          bullet.removeFromParent();
          enemy.hitCount += 1;
          if (enemy.hitCount >= 5) {
            enemy.removeFromParent();
          }
        }
      });

      // bullets vs BossRobot
      if (boss != null && bullet.toRect().overlaps(boss!.toRect())) {
        bullet.removeFromParent();
        boss!.hitCount += 1;
        if (boss!.hitCount >= 100) {
          // 1) Hapus boss dari game
          boss!.removeFromParent();
          boss = null;

          // 2) Pause game supaya animasi berhenti
          pauseEngine();

          // 3) Panggil overlay Epilogue
          overlays.add('EpilogueOverlay');
        }
      }
    });

    // Coin collision
    children.whereType<Coin>().toList().forEach((coin) {
      if (player.toRect().overlaps(coin.toRect())) {
        controller.addScore(1);
        if (controller.score == 50 && !prologueShown) {
          pauseEngine();
          overlays.add('PrologueOverlay');
          prologueShown = true;
          changeAssets();
        } else if (controller.score == 100 && !prologueEndingShown) {
          pauseEngine();
          overlays.add('PrologueOverlayEnding');
          prologueEndingShown = true;
          changeAssets2();
        }
        coin.removeFromParent();
      }
    });

    // Enemy collision
    children.whereType<EnemyRobot>().toList().forEach((enemy) {
      if (player.toRect().overlaps(enemy.toRect())) {
        controller.addScore(-1);
        enemy.removeFromParent();
      }
    });

    // Laser boss collision
    children.whereType<Laser>().toList().forEach((laser) {
      if (player.toRect().overlaps(laser.toRect())) {
        controller.addScore(-5);
        laser.removeFromParent();
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
    final newBgSprite = await loadSprite('background_3.png');
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
    bossSpawned = false;
    boss = null;
    hasGun = false;
    bulletTimer.stop();
  }

  void spawnBoss() async {
    final bossSprite = await loadSprite('boss_robot.png');
    boss = BossRobot(sprite: bossSprite);
    add(boss!);
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
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!isInitialized) {
      position = Vector2(50, size.y / 2);
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
  int hitCount = 0;
  EnemyRobot({super.sprite});
}

class BossRobot extends SpriteComponent with HasGameRef<JetpackGame> {
  int hitCount = 0;
  Timer? laserTimer;

  BossRobot({super.sprite});

  @override
  Future<void> onLoad() async {
    size = Vector2(300, 300);
    position = Vector2(gameRef.size.x - 350, gameRef.size.y / 2 - 150);
    laserTimer = Timer(2, repeat: true, onTick: fireLaser)..start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    laserTimer?.update(dt);
  }

  void fireLaser() async {
    final laserSprite = await gameRef.loadSprite('laser.png');
    final laser = Laser(sprite: laserSprite)
      ..size = Vector2(150, 20)
      ..position = Vector2(position.x - 100, position.y + size.y / 2 - 10);
    gameRef.add(laser);
    laser.add(
      MoveEffect.to(
        Vector2(-100, laser.y),
        EffectController(duration: 2),
        onComplete: () => laser.removeFromParent(),
      ),
    );
  }
}

class Laser extends SpriteComponent {
  Laser({super.sprite}) {
    size = Vector2(150, 20);
  }
}

// Bullet yang ditembakkan player
class Bullet extends SpriteComponent with HasGameRef<JetpackGame> {
  Bullet({super.sprite}) {
    size = Vector2(60, 20);
  }

  @override
  Future<void> onLoad() async {
    position = Vector2(
      gameRef.player.x + gameRef.player.size.x,
      gameRef.player.y + gameRef.player.size.y / 2 - size.y / 2,
    );
    add(
      MoveEffect.to(
        Vector2(gameRef.size.x + size.x, y),
        EffectController(duration: 1.0),
        onComplete: () => removeFromParent(),
      ),
    );
  }
}

// Item yang memberikan kemampuan menembak
class GunItem extends SpriteComponent {
  GunItem({super.sprite}) {
    size = Vector2(70, 70);
  }
}
