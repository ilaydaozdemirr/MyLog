import 'dart:math';
import 'package:flutter/material.dart';

class SnowfallWidget extends StatefulWidget {
  const SnowfallWidget({super.key});

  @override
  State<SnowfallWidget> createState() => _SnowfallWidgetState();
}

class _SnowfallWidgetState extends State<SnowfallWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Snowflake> _flakes;
  final int _flakeCount = 60;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _flakes = List.generate(_flakeCount, (index) => Snowflake());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SnowfallPainter(_flakes, _controller.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class Snowflake {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double radius = Random().nextDouble() * 4 + 2;
  double speed = Random().nextDouble() * 0.5 + 0.5;
  double drift = (Random().nextDouble() - 0.5) * 0.01;
  Color color = Colors.white.withOpacity(0.8);

  void update(double progress) {
    y += speed * 0.01;
    x += drift * 0.5;
    if (y > 1.0) y -= 1.0;
    if (x > 1.0) x -= 1.0;
    if (x < 0.0) x += 1.0;
  }
}

class SnowfallPainter extends CustomPainter {
  final List<Snowflake> flakes;
  final double progress;

  SnowfallPainter(this.flakes, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var flake in flakes) {
      flake.update(progress);
      paint.color = flake.color;
      canvas.drawCircle(
        Offset(flake.x * size.width, flake.y * size.height),
        flake.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SnowfallPainter oldDelegate) => true;
}
