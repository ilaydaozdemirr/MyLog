import 'package:flutter/material.dart';
import 'dart:math';

class SnowfallBackground extends StatefulWidget {
  const SnowfallBackground({super.key});

  @override
  _SnowfallBackgroundState createState() => _SnowfallBackgroundState();
}

class _SnowfallBackgroundState extends State<SnowfallBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Snowflake> _snowflakes = [];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..addListener(() {
            setState(() {
              for (var snowflake in _snowflakes) {
                snowflake.update();
              }
            });
          })
          ..repeat();

    for (int i = 0; i < 100; i++) {
      _snowflakes.add(Snowflake());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: SnowPainter(_snowflakes), child: Container());
  }
}

class Snowflake {
  double x = Random().nextDouble() * 400;
  double y = Random().nextDouble() * 800;
  double radius = Random().nextDouble() * 3 + 2;
  double speed = Random().nextDouble() * 2 + 1;

  void update() {
    y += speed;
    if (y > 800) {
      y = 0;
      x = Random().nextDouble() * 400;
    }
  }
}

class SnowPainter extends CustomPainter {
  final List<Snowflake> snowflakes;
  SnowPainter(this.snowflakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    for (var snowflake in snowflakes) {
      canvas.drawCircle(
        Offset(snowflake.x, snowflake.y),
        snowflake.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
