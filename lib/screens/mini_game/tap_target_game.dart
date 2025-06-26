// lib/screens/mini_game/tap_target.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TapTargetScreen extends StatefulWidget {
  const TapTargetScreen({super.key});

  @override
  State<TapTargetScreen> createState() => _TapTargetScreenState();
}

class _TapTargetScreenState extends State<TapTargetScreen> {
  static const Duration gameDuration = Duration(seconds: 20);

  int score = 0;
  Timer? _timer;
  Duration _timeLeft = gameDuration;
  Offset _targetPosition = Offset.zero;
  double _targetSize = 50.0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Esperem a què es construeixi la UI per calcular grandàries
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGame());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    final size = MediaQuery.of(context).size;
    _randomizeTarget(size);
    score = 0;
    _timeLeft = gameDuration;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds <= 1) {
        timer.cancel();
        _showGameOver();
      } else {
        setState(() => _timeLeft -= const Duration(seconds: 1));
      }
    });
    setState(() {}); // refresca marcador i comptador
  }

  void _randomizeTarget(Size size) {
    final x = _random.nextDouble() * (size.width - _targetSize);
    final y = _random.nextDouble() * (size.height - _targetSize - 100) + 100;
    _targetPosition = Offset(x, y);
  }

  void _onTapDown(TapDownDetails details) {
    final tap = details.localPosition;
    final rect = _targetPosition & Size(_targetSize, _targetSize);
    if (rect.contains(tap)) {
      score++;
      _randomizeTarget(MediaQuery.of(context).size);
      setState(() {});
    }
  }

  void _showGameOver() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(loc.gameOverTitle),
        content: Text(loc.tapTargetScore(score)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
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
  Widget build(BuildContext context) {
    final loc    = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final pct    = _timeLeft.inSeconds / gameDuration.inSeconds;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/play-testing')),
        title: Text(loc.tapTargetTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: colors.primary,
        elevation: 2,
      ),
      backgroundColor: colors.surfaceVariant,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: _onTapDown,
        child: Stack(
          children: [
            // Comptador restant
            Positioned(
              top: 16,
              left: 16,
              child: Text(
                '${loc.timeLabel}: ${_timeLeft.inSeconds}s',
                style: TextStyle(color: colors.onSurface, fontSize: 16),
              ),
            ),
            // Puntuació
            Positioned(
              top: 16,
              right: 16,
              child: Text(
                '${loc.scoreLabel}: $score',
                style: TextStyle(color: colors.onSurface, fontSize: 16),
              ),
            ),
            // Objectiu mòbil
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: _targetPosition.dx,
              top: _targetPosition.dy,
              child: Container(
                width: _targetSize,
                height: _targetSize,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.onSurface.withOpacity(0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
            // Barra de temps
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                color: colors.primary,
                backgroundColor: colors.primary.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
