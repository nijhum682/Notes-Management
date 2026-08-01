import 'dart:math' as math;
import 'package:flutter/material.dart';

class InteractiveBackground extends StatefulWidget {
  final Widget child;
  const InteractiveBackground({super.key, required this.child});

  @override
  State<InteractiveBackground> createState() => _InteractiveBackgroundState();
}

class _InteractiveBackgroundState extends State<InteractiveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Blob> _blobs = [];
  Offset _mousePosition = Offset.zero;
  final int _blobCount = 4;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    final List<Color> colors = [
      const Color(0xFF3B82F6).withOpacity(0.18),
      const Color(0xFF8B5CF6).withOpacity(0.18),
      const Color(0xFF06B6D4).withOpacity(0.15),
      const Color(0xFFEC4899).withOpacity(0.12),
    ];

    for (int i = 0; i < _blobCount; i++) {
      _blobs.add(Blob(
        color: colors[i % colors.length],
        radius: 120.0 + _random.nextDouble() * 100,
        speed: 0.2 + _random.nextDouble() * 0.4,
        random: _random,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _mousePosition = event.localPosition;
        });
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                color: const Color(0xFF0B0F19),
              ),
              CustomPaint(
                painter: BlobPainter(
                  blobs: _blobs,
                  mousePos: _mousePosition,
                  time: _controller.value,
                ),
                size: Size.infinite,
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
              Positioned.fill(child: widget.child),
            ],
          );
        },
      ),
    );
  }
}

class Blob {
  late double x;
  late double y;
  final double radius;
  final double speed;
  final Color color;
  double angle = 0.0;

  Blob({
    required this.radius,
    required this.speed,
    required this.color,
    required math.Random random,
  }) {
    x = random.nextDouble() * 800;
    y = random.nextDouble() * 600;
    angle = random.nextDouble() * math.pi * 2;
  }

  void update(Size size, Offset mousePos) {
    angle += (math.Random().nextDouble() - 0.5) * 0.1;
    x += math.cos(angle) * speed;
    y += math.sin(angle) * speed;

    if (x < -radius) x = size.width + radius;
    if (x > size.width + radius) x = -radius;
    if (y < -radius) y = size.height + radius;
    if (y > size.height + radius) y = -radius;

    double dx = mousePos.dx - x;
    double dy = mousePos.dy - y;
    double distance = math.sqrt(dx * dx + dy * dy);
    if (distance < 350 && distance > 10) {
      x += (dx / distance) * 0.8;
      y += (dy / distance) * 0.8;
    }
  }
}

class BlobPainter extends CustomPainter {
  final List<Blob> blobs;
  final Offset mousePos;
  final double time;

  BlobPainter({
    required this.blobs,
    required this.mousePos,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var blob in blobs) {
      blob.update(size, mousePos);

      final Paint paint = Paint()
        ..color = blob.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blob.radius * 0.65)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(blob.x, blob.y), blob.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BlobPainter oldDelegate) => true;
}