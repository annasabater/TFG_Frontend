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
  static const gameDuration = Duration(seconds: 20);
  int score = 0;
  Timer? _timer;
  Duration _timeLeft = gameDuration;
  Offset _targetPosition = Offset.zero;
  double _targetSize = 50;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGame();
    });
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
        setState(() {
          _timeLeft -= const Duration(seconds: 1);
        });
      }
    });
    setState(() {}); // refresca tiempo y marcador
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
    final loc = AppLocalizations.of(context)!;
    final timePct = _timeLeft.inSeconds / gameDuration.inSeconds;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/play-testing')),
        title: Text(loc.tapTargetTitle),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.lightBlue[100],
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: _onTapDown,
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: Text('${loc.timeLabel}: ${_timeLeft.inSeconds}s'),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Text('${loc.scoreLabel}: $score'),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: _targetPosition.dx,
              top: _targetPosition.dy,
              child: Container(
                width: _targetSize,
                height: _targetSize,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: timePct,
                minHeight: 8,
                color: Colors.grey[600],           // barra de progreso gris
                backgroundColor: Colors.grey[300],  // fondo de la barra
              ),
            ),
          ],
        ),
      ),
    );
  }
}
