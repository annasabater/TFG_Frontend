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
  static const int spawnIntervalMs = 500;
  static const int tickIntervalMs  = 100;

  final Random _rand = Random();
  Timer? _spawnTimer;
  Timer? _countdownTimer;
  Stopwatch _stopwatch = Stopwatch();

  int _timeLeftMs    = 10000;
  bool _flashVisible = false;
  Offset _flashPos   = Offset.zero;
  Size _flashSize    = Size.zero;
  Color? _flashColor;

  int _greenHits = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _timeLeftMs    = 10000;
    _greenHits     = 0;
    _flashVisible  = false;
    _stopwatch     = Stopwatch()..start();

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
      // 30% vermell, 70% verd
      final isRed = _rand.nextDouble() < 0.3;
      _flashColor = isRed ? Colors.red : Colors.green;

      final screen = MediaQuery.of(context).size;
      final w      = screen.width * (0.1 + _rand.nextDouble() * 0.1);
      final x      = _rand.nextDouble() * (screen.width - w);
      final y      = _rand.nextDouble() * (screen.height - w - 100) + 50;

      _flashSize    = Size(w, w);
      _flashPos     = Offset(x, y);
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
          _timeLeftMs += 800;
        } else {
          _timeLeftMs = 0;
        }
      });
      if (_timeLeftMs <= 0) _endGame();
    }
  }

  void _endGame() {
    _spawnTimer?.cancel();
    _countdownTimer?.cancel();
    _stopwatch.stop();

    final loc    = AppLocalizations.of(context)!;
    final played = (_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(loc.reactionTitle),
        content: Text('⏱ $played s\n✅ $_greenHits'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.reactionTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: colors.primary,
        leading: BackButton(onPressed: () => context.go('/play-testing')),
      ),
      backgroundColor: colors.surfaceVariant,
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
                style: TextStyle(color: colors.onSurface, fontSize: 18),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Text(
                '✅ $_greenHits',
                style: TextStyle(color: colors.onSurface, fontSize: 18),
              ),
            ),
            if (_flashVisible && _flashColor != null)
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
