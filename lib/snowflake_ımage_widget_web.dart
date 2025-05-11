import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnowflakeImageWidgetWeb extends StatefulWidget {
  const SnowflakeImageWidgetWeb({super.key});

  @override
  State<SnowflakeImageWidgetWeb> createState() =>
      _SnowflakeImageWidgetWebState();
}

class _SnowflakeImageWidgetWebState extends State<SnowflakeImageWidgetWeb> {
  final List<_SnowflakePosition> _snowflakes = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateSnowflakes();

    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      setState(() {
        for (var flake in _snowflakes) {
          flake.y += flake.speedY;
          if (flake.y > MediaQuery.of(context).size.height) {
            flake.y = -20;
            flake.x = _random.nextDouble() * MediaQuery.of(context).size.width;
          }
        }
      });
    });
  }

  void _generateSnowflakes() {
    for (int i = 0; i < 80; i++) {
      _snowflakes.add(
        _SnowflakePosition(
          x: _random.nextDouble() * 1600,
          y: _random.nextDouble() * 900,
          speedY: 1 + _random.nextDouble() * 1.5,
          size: 27 + _random.nextDouble() * 12,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children:
            _snowflakes.map((flake) {
              return Positioned(
                top: flake.y,
                left: flake.x,
                child: Image.asset(
                  'web/assets/snowflakess.png',
                  width: flake.size,
                  height: flake.size,
                  color: Colors.white.withOpacity(0.85),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _SnowflakePosition {
  double x;
  double y;
  double speedY;
  double size;

  _SnowflakePosition({
    required this.x,
    required this.y,
    required this.speedY,
    required this.size,
  });
}
