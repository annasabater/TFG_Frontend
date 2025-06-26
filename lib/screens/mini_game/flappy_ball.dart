// lib/screens/mini_game/flappy_ball.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FlappyBallScreen extends StatefulWidget {
  const FlappyBallScreen({super.key});

  @override
  State<FlappyBallScreen> createState() => _FlappyBallScreenState();
}

class _FlappyBallScreenState extends State<FlappyBallScreen> {
  late double screenW, screenH;
  double y = 0, vy = 0;
  final double radius     = 20;
  final gravity           = 800.0;
  final double pipeWidth  = 60;
  final double pipeGap    = 200;
  final double pipeSpeed  = 150;
  List<double> pipeX      = [];
  List<double> pipeTopH   = [];
  final rnd               = Random();
  Timer? gameTimer;
  bool gameOver = false;
  int score     = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = MediaQuery.of(context).size;
      screenW = s.width;
      screenH = s.height;
      y = screenH / 2;
      for (int i = 0; i < 3; i++) _addNewPipe(i);
      gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => _update());
    });
  }

  void _addNewPipe(int i) {
    pipeX.add(screenW + i * (screenW / 2));
    pipeTopH.add(rnd.nextDouble() * (screenH - pipeGap - 200) + 50);
  }

  void _update() {
    if (gameOver) return;
    final dt = 16 / 1000;
    vy += gravity * dt;
    y  += vy * dt;

    for (int i = 0; i < pipeX.length; i++) {
      pipeX[i] -= pipeSpeed * dt;
      if (pipeX[i] + pipeWidth < 0) {
        pipeX[i]    = screenW;
        pipeTopH[i] = rnd.nextDouble() * (screenH - pipeGap - 200) + 50;
        score++;
      }
    }

    final ballRect = Rect.fromCircle(center: Offset(50, y), radius: radius);
    for (int i = 0; i < pipeX.length; i++) {
      final topRect = Rect.fromLTWH(pipeX[i], 0, pipeWidth, pipeTopH[i]);
      final botRect = Rect.fromLTWH(pipeX[i], pipeTopH[i] + pipeGap, pipeWidth, screenH - (pipeTopH[i] + pipeGap));
      if (ballRect.overlaps(topRect) || ballRect.overlaps(botRect)) {
        _onGameOver();
        return;
      }
    }
    if (y - radius < 0 || y + radius > screenH) {
      _onGameOver();
      return;
    }

    setState(() {});
  }

  void _flap() {
    if (!gameOver) vy = -400;
  }

  void _onGameOver() {
    gameOver = true;
    gameTimer?.cancel();
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(loc.gameOverTitle),
        content: Text(loc.scoreText(score)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                pipeX.clear();
                pipeTopH.clear();
                score   = 0;
                vy      = 0;
                y       = screenH / 2;
                gameOver = false;
                for (int i = 0; i < 3; i++) _addNewPipe(i);
                gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => _update());
              });
            },
            child: Text(loc.playAgain),
          ),
          TextButton(
            onPressed: () => context.go('/play-testing'),
            child: Text(loc.endGame),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc    = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/play-testing')),
        title: Text(loc.flappyBallTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: colors.primary,
      ),
      backgroundColor: colors.surfaceVariant,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _flap,
        child: CustomPaint(
          size: Size.infinite,
          painter: _FlappyPainter(
            y, radius, pipeX, pipeTopH, pipeWidth, pipeGap, score, colors, loc
          ),
        ),
      ),
    );
  }
}

class _FlappyPainter extends CustomPainter {
  final double y, r, pipeW, pipeGap;
  final List<double> pipeX, pipeTopH;
  final int score;
  final ColorScheme colors;
  final AppLocalizations loc;

  _FlappyPainter(
    this.y,
    this.r,
    this.pipeX,
    this.pipeTopH,
    this.pipeW,
    this.pipeGap,
    this.score,
    this.colors,
    this.loc,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Bola taronja
    paint.color = colors.primary; // pots fer colors.primaryVariant si vols més intens
    canvas.drawCircle(Offset(50, y), r, paint);

    // Tubs en gris suau
    paint.color = colors.onSurface.withOpacity(0.6);
    for (int i = 0; i < pipeX.length; i++) {
      canvas.drawRect(Rect.fromLTWH(pipeX[i], 0, pipeW, pipeTopH[i]), paint);
      canvas.drawRect(
        Rect.fromLTWH(pipeX[i], pipeTopH[i] + pipeGap, pipeW, size.height - (pipeTopH[i] + pipeGap)),
        paint,
      );
    }

    // Puntuació
    final tp = TextPainter(
      text: TextSpan(
        text: loc.scoreText(score),
        style: TextStyle(
          color: colors.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, const Offset(20, 20));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
