// lib/screens/mini_game/pluja_asteroides.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlujaAsteroidesScreen extends StatefulWidget {
  const PlujaAsteroidesScreen({super.key});

  @override
  State<PlujaAsteroidesScreen> createState() => _PlujaAsteroidesScreenState();
}

class _PlujaAsteroidesScreenState extends State<PlujaAsteroidesScreen> {
  static const double playerSize = 50.0;
  static const double asteroidSize = 40.0;
  static const double heartSize = 30.0;
  static const double moveSpeed = 8.0;

  double? playerX;
  double? playerY;
  List<Offset> asteroids = [];
  List<Offset> hearts = [];
  late Timer gameTimer;
  late Stopwatch stopwatch;
  int lives = 3;
  bool gameOver = false;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch()..start();
    startGame();
  }

  @override
  void dispose() {
    gameTimer.cancel();
    stopwatch.stop();
    super.dispose();
  }

  void startGame() {
    setState(() {
      asteroids.clear();
      hearts.clear();
      lives = 3;
      gameOver = false;
      stopwatch
        ..reset()
        ..start();
    });
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => updateGame());
  }

  void updateGame() {
    if (!mounted || gameOver) return;
    final size = MediaQuery.of(context).size;
    playerX ??= size.width / 2 - playerSize / 2;
    playerY ??= size.height - playerSize * 2;
    setState(() {
      asteroids = asteroids.map((a) => Offset(a.dx, a.dy + 5)).toList();
      hearts = hearts.map((h) => Offset(h.dx, h.dy + 3)).toList();
      if (random.nextDouble() < 0.03) {
        asteroids.add(
          Offset(random.nextDouble() * (size.width - asteroidSize), -asteroidSize),
        );
      }
      if (random.nextDouble() < 0.003) {
        hearts.add(
          Offset(random.nextDouble() * (size.width - heartSize), -heartSize),
        );
      }
      _checkCollisions();
      asteroids.removeWhere((a) => a.dy > size.height);
      hearts.removeWhere((h) => h.dy > size.height);
    });
  }

  void _checkCollisions() {
    for (var a in List.of(asteroids)) {
      if (playerX! < a.dx + asteroidSize &&
          playerX! + playerSize > a.dx &&
          playerY! < a.dy + asteroidSize &&
          playerY! + playerSize > a.dy) {
        asteroids.remove(a);
        lives--;
        if (lives <= 0) {
          gameOver = true;
          gameTimer.cancel();
          stopwatch.stop();
        }
      }
    }
    for (var h in List.of(hearts)) {
      if (playerX! < h.dx + heartSize &&
          playerX! + playerSize > h.dx &&
          playerY! < h.dy + heartSize &&
          playerY! + playerSize > h.dy) {
        hearts.remove(h);
        if (lives < 3) lives++;
      }
    }
  }

  void _handleKey(RawKeyEvent event) {
    if (!mounted || gameOver || playerX == null) return;
    final size = MediaQuery.of(context).size;
    setState(() {
      if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
        playerX = (playerX! - moveSpeed).clamp(0, size.width - playerSize);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
        playerX = (playerX! + moveSpeed).clamp(0, size.width - playerSize);
      }
    });
  }

  void _moveLeft() {
    final size = MediaQuery.of(context).size;
    setState(() {
      playerX = (playerX! - moveSpeed * 10).clamp(0, size.width - playerSize);
    });
  }

  void _moveRight() {
    final size = MediaQuery.of(context).size;
    setState(() {
      playerX = (playerX! + moveSpeed * 10).clamp(0, size.width - playerSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    playerX ??= size.width / 2 - playerSize / 2;
    playerY ??= size.height - playerSize * 2;

    String timeText() {
      final ms = stopwatch.elapsedMilliseconds;
      final s = (ms / 1000).floor();
      final cs = ((ms % 1000) / 10).floor().toString().padLeft(2, '0');
      return '$s.$cs';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(loc.plujaAsteroidesTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: colors.primary,
        elevation: 2,
      ),
      backgroundColor: colors.surfaceVariant,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: _handleKey,
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: Text(loc.timePlayed(timeText()), style: TextStyle(color: colors.onSurface, fontSize: 18)),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Row(
                children: List.generate(3, (i) => Icon(
                  Icons.favorite,
                  color: i < lives ? colors.error : colors.onSurface.withOpacity(0.3),
                  size: 28,
                )),
              ),
            ),
            Positioned(
              left: playerX!,
              top: playerY!,
              child: CustomPaint(
                size: const Size(playerSize, playerSize),
                painter: DronePainter(color: colors.primary),
              ),
            ),
            ...asteroids.map((a) => Positioned(
              left: a.dx,
              top: a.dy,
              child: Container(
                width: asteroidSize,
                height: asteroidSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [colors.errorContainer, colors.error],
                  ),
                ),
              ),
            )),
            ...hearts.map((h) => Positioned(
              left: h.dx,
              top: h.dy,
              child: Icon(Icons.favorite, color: colors.error, size: heartSize),
            )),
            if (gameOver) Center(
              child: AlertDialog(
                backgroundColor: colors.surface,
                title: Text(loc.plujaAsteroidesGameOverTitle),
                content: Text(
                  '${loc.timePlayed(timeText())}\n${loc.plujaAsteroidesSummary(lives)}',
                ),
                actions: [
                  TextButton(
                    onPressed: startGame,
                    child: Text(loc.playAgain),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(loc.exitGame),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTapDown: (_) => _moveLeft(),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_left, color: Colors.white),
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (_) => _moveRight(),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_right, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DronePainter extends CustomPainter {
  final Color color;
  DronePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final body = Path()
      ..moveTo(size.width * 0.2, size.height * 0.4)
      ..lineTo(size.width * 0.8, size.height * 0.4)
      ..lineTo(size.width * 0.6, size.height * 0.8)
      ..lineTo(size.width * 0.4, size.height * 0.8)
      ..close();
    canvas.drawPath(body, paint);

    paint.color = color.withOpacity(0.8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.3, size.height * 0.3),
        width: size.width * 0.3,
        height: size.height * 0.1,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.7, size.height * 0.3),
        width: size.width * 0.3,
        height: size.height * 0.1,
      ),
      paint,
    );

    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.05,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}