// lib/screens/mini_game/reaction_game.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReactionGameScreen extends StatefulWidget {
  const ReactionGameScreen({super.key});

  @override
  State<ReactionGameScreen> createState() => _ReactionGameScreenState();
}

class _ReactionGameScreenState extends State<ReactionGameScreen> {
  static const int spawnIntervalMs = 500; // cada 200 ms aparece un cuadrado ⇒ 5/s
  static const int tickIntervalMs = 100;  // rebaja tiempo cada 0,1 s

  final Random _rand = Random();
  Timer? _spawnTimer;
  Timer? _countdownTimer;
  Stopwatch _stopwatch = Stopwatch();

  int _timeLeftMs = 10000;   // empieza en 10 s
  bool _flashVisible = false;
  Offset _flashPos = Offset.zero;
  Size _flashSize = Size.zero;
  Color _flashColor = Colors.green;

  int _greenHits = 0;        // cuenta sólo verdes

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _timeLeftMs = 10000;
    _greenHits = 0;
    _flashVisible = false;
    _stopwatch = Stopwatch()..start();

    _spawnTimer?.cancel();
    _countdownTimer?.cancel();

    _spawnTimer = Timer.periodic(
      const Duration(milliseconds: spawnIntervalMs),
      (_) => _spawnFlash(),
    );
    _countdownTimer = Timer.periodic(
      const Duration(milliseconds: tickIntervalMs),
      (_) => _onTick(),
    );
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _spawnFlash() {
    if (_timeLeftMs <= 0) return;
    setState(() {
      _flashColor = _rand.nextDouble() < 0.3 ? Colors.red : Colors.green;
      Size screen = MediaQuery.of(context).size;
      double w = screen.width * (0.1 + _rand.nextDouble() * 0.1);
      double x = _rand.nextDouble() * (screen.width - w);
      double y = _rand.nextDouble() * (screen.height - w - 100) + 50;
      _flashSize = Size(w, w);
      _flashPos = Offset(x, y);
      _flashVisible = true;
    });
  }

  void _onTick() {
    if (_timeLeftMs <= 0) return;
    setState(() {
      _timeLeftMs -= tickIntervalMs;
      if (_timeLeftMs <= 0) {
        _timeLeftMs = 0;
        _endGame();
      }
    });
  }

  void _onTapDown(TapDownDetails details) {
    if (!_flashVisible) return;
    final tap = details.localPosition;
    if ((_flashPos & _flashSize).contains(tap)) {
      setState(() {
        _flashVisible = false;
        if (_flashColor == Colors.green) {
          _greenHits++;
          _timeLeftMs += 800;   // +0,8 s
        } else {
          // rojo ⇒ fin del juego inmediato
          _timeLeftMs = 0;
        }
      });
      if (_timeLeftMs <= 0) {
        _endGame();
      }
    }
  }

  void _endGame() {
    _spawnTimer?.cancel();
    _countdownTimer?.cancel();
    _stopwatch.stop();

    final loc = AppLocalizations.of(context)!;
    final totalPlayedSec = (_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(loc.reactionTitle),
        content: Text(
          '⏱ Tiempo jugado: ${totalPlayedSec}s\n'
          '✅ Cuadros verdes: $_greenHits',
        ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.reactionTitle),
        backgroundColor: Colors.blue,
        leading: BackButton(onPressed: () => context.go('/play-testing')),
      ),
      backgroundColor: Colors.lightBlue[100],
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: Text(
                '${loc.timeLeftLabel}: ${(_timeLeftMs / 1000).toStringAsFixed(1)}s',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Text(
                '✅: $_greenHits',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            if (_flashVisible)
              Positioned(
                left: _flashPos.dx,
                top: _flashPos.dy,
                child: Container(
                  width: _flashSize.width,
                  height: _flashSize.height,
                  color: _flashColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
