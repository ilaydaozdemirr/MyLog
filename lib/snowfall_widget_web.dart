import 'dart:math';
import 'package:flutter/material.dart';

class SnowfallWidgetWeb extends StatefulWidget {
  const SnowfallWidgetWeb({super.key});

  @override
  State<SnowfallWidgetWeb> createState() => _SnowfallWidgetWebState();
}

class _SnowfallWidgetWebState extends State<SnowfallWidgetWeb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Snowflake> _snowflakes = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(hours: 1),
      vsync: this,
    )..addListener(() {
      setState(() {
        for (var snowflake in _snowflakes) {
          snowflake.fall();
        }
      });
    });

    final random = Random();
    for (int i = 0; i < 250; i++) {
      _snowflakes.add(
        Snowflake(
          x: random.nextDouble() * 1600,
          y: random.nextDouble() * 1200,
          radius: 2 + random.nextDouble() * 3,
          speedY: 1 + random.nextDouble() * 1.5,
        ),
      );
    }

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SnowfallPainter(_snowflakes),
      size: Size.infinite,
    );
  }
}

class Snowflake {
  double x;
  double y;
  double radius;
  double speedY;

  Snowflake({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedY,
  });

  void fall() {
    y += speedY;
    if (y > 1000) y = -10;
  }
}

class SnowfallPainter extends CustomPainter {
  final List<Snowflake> snowflakes;

  SnowfallPainter(this.snowflakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.7);

    for (var flake in snowflakes) {
      canvas.drawCircle(Offset(flake.x, flake.y), flake.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
