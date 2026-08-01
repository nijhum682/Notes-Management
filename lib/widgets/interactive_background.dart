import 'dart:math' as math;
import 'dart:ui';
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
  Offset _smoothMousePosition = Offset.zero;
  final int _blobCount = 5;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Vibrant modern glowing colors (increased opacity for rich visuals)
    final List<Color> colors = [
      const Color(0xFF3B82F6).withOpacity(0.35), // Electric Blue
      const Color(0xFF8B5CF6).withOpacity(0.35), // Purple Glow
      const Color(0xFF06B6D4).withOpacity(0.32), // Cyan Accent
      const Color(0xFFEC4899).withOpacity(0.28), // Pink Glow
      const Color(0xFF10B981).withOpacity(0.25), // Emerald Glow
    ];

    for (int i = 0; i < _blobCount; i++) {
      _blobs.add(Blob(
        color: colors[i % colors.length],
        radius: 200.0 + _random.nextDouble() * 150, // Much larger blobs
        speed: 0.5 + _random.nextDouble() * 0.8,    // Slightly faster drift
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
          // Smoothly interpolate cursor tracking position
          _smoothMousePosition = Offset.lerp(_smoothMousePosition, _mousePosition, 0.05) ?? _mousePosition;

          return Stack(
            children: [
              // Deep dark premium background
              Container(
                color: const Color(0xFF090D16), // Darker midnight canvas
              ),
              // Glowing fluid mesh blobs using Shader Radial Gradients (100% Web Compatible)
              CustomPaint(
                painter: BlobPainter(
                  blobs: _blobs,
                  mousePos: _smoothMousePosition,
                  time: _controller.value,
                ),
                size: Size.infinite,
              ),
              // Glassmorphic backdrop blur overlay to blend the mesh gradient
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(
                      color: Colors.black.withOpacity(0.25), // Dim overlay
                    ),
                  ),
                ),
              ),
              // The main content of the app
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
    x = random.nextDouble() * 1000;
    y = random.nextDouble() * 800;
    angle = random.nextDouble() * math.pi * 2;
  }

  void update(Size size, Offset mousePos) {
    // Drifts around randomly but stays bound
    angle += (math.Random().nextDouble() - 0.5) * 0.15;
    x += math.cos(angle) * speed;
    y += math.sin(angle) * speed;

    // Boundary wrapping
    if (x < -radius) x = size.width + radius;
    if (x > size.width + radius) x = -radius;
    if (y < -radius) y = size.height + radius;
    if (y > size.height + radius) y = -radius;

    // React to mouse: gentle attraction
    double dx = mousePos.dx - x;
    double dy = mousePos.dy - y;
    double distance = math.sqrt(dx * dx + dy * dy);
    if (distance < 400 && distance > 10) {
      x += (dx / distance) * 0.5;
      y += (dy / distance) * 0.5;
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
    // 1. Draw drifting glowing blobs
    for (var blob in blobs) {
      blob.update(size, mousePos);

      final Paint paint = Paint()
        ..shader = RadialGradient(
          colors: [
            blob.color,
            blob.color.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(blob.x, blob.y),
          radius: blob.radius,
        ))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(blob.x, blob.y), blob.radius, paint);
    }

    // 2. Draw dynamic cursor-following glow
    if (mousePos != Offset.zero) {
      final Color cursorGlowColor = const Color(0xFF3B82F6).withOpacity(0.35); // Blue glow
      final double cursorGlowRadius = 250.0;

      final Paint cursorPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            cursorGlowColor,
            cursorGlowColor.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(
          center: mousePos,
          radius: cursorGlowRadius,
        ))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(mousePos, cursorGlowRadius, cursorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BlobPainter oldDelegate) => true;
}
