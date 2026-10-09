import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'colors.dart';

class LvmEmblem extends StatelessWidget {
  const LvmEmblem({super.key, this.size = 112});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const Key('lvm-emblem'),
      label: 'Emblema de La Voz Misionera: libro abierto, paloma y llama',
      child: CustomPaint(
        size: Size.square(size),
        painter: const _LvmEmblemPainter(),
      ),
    );
  }
}

class _LvmEmblemPainter extends CustomPainter {
  const _LvmEmblemPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = side / 2;
    final white = Paint()..color = Colors.white;

    canvas.drawCircle(center, radius, Paint()..color = LvmColors.navy);

    final flame = Path()
      ..moveTo(center.dx, center.dy - radius * 0.68)
      ..quadraticBezierTo(
        center.dx + radius * 0.34,
        center.dy - radius * 0.28,
        center.dx + radius * 0.08,
        center.dy - radius * 0.08,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy - radius * 0.28,
        center.dx - radius * 0.08,
        center.dy - radius * 0.08,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.34,
        center.dy - radius * 0.28,
        center.dx,
        center.dy - radius * 0.68,
      )
      ..close();
    canvas.drawPath(flame, white);

    final dove = Path()
      ..moveTo(center.dx - radius * 0.34, center.dy + radius * 0.02)
      ..quadraticBezierTo(
        center.dx - radius * 0.02,
        center.dy - radius * 0.24,
        center.dx + radius * 0.30,
        center.dy - radius * 0.02,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.08,
        center.dy + radius * 0.04,
        center.dx - radius * 0.02,
        center.dy + radius * 0.08,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.22,
        center.dy + radius * 0.20,
        center.dx - radius * 0.40,
        center.dy + radius * 0.06,
      )
      ..close();
    canvas.drawPath(dove, white);

    final page = Radius.circular(radius * 0.05);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - radius * 0.22, center.dy + radius * 0.42),
          width: radius * 0.40,
          height: radius * 0.22,
        ),
        page,
      ),
      white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.22, center.dy + radius * 0.42),
          width: radius * 0.40,
          height: radius * 0.22,
        ),
        page,
      ),
      white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
