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

    Offset at(double x, double y) =>
        Offset(center.dx + radius * x, center.dy + radius * y);

    canvas.drawPath(_flame(at), white);
    _drawDove(canvas, at, radius, white);
    canvas.drawPath(_page(at, left: true), white);
    canvas.drawPath(_page(at, left: false), white);
  }

  Path _flame(Offset Function(double x, double y) at) {
    return Path()
      ..moveTo(at(0, -0.76).dx, at(0, -0.76).dy)
      ..cubicTo(
        at(0.20, -0.58).dx,
        at(0.20, -0.58).dy,
        at(0.28, -0.36).dx,
        at(0.28, -0.36).dy,
        at(0.08, -0.20).dx,
        at(0.08, -0.20).dy,
      )
      ..cubicTo(
        at(0.04, -0.34).dx,
        at(0.04, -0.34).dy,
        at(0.01, -0.28).dx,
        at(0.01, -0.28).dy,
        at(0, -0.14).dx,
        at(0, -0.14).dy,
      )
      ..cubicTo(
        at(-0.01, -0.28).dx,
        at(-0.01, -0.28).dy,
        at(-0.04, -0.34).dx,
        at(-0.04, -0.34).dy,
        at(-0.08, -0.20).dx,
        at(-0.08, -0.20).dy,
      )
      ..cubicTo(
        at(-0.28, -0.36).dx,
        at(-0.28, -0.36).dy,
        at(-0.20, -0.58).dx,
        at(-0.20, -0.58).dy,
        at(0, -0.76).dx,
        at(0, -0.76).dy,
      )
      ..close();
  }

  void _drawDove(
    Canvas canvas,
    Offset Function(double x, double y) at,
    double radius,
    Paint white,
  ) {
    final tail = Path()
      ..moveTo(at(-0.74, 0.08).dx, at(-0.74, 0.08).dy)
      ..lineTo(at(-0.40, 0.15).dx, at(-0.40, 0.15).dy)
      ..lineTo(at(-0.72, 0.26).dx, at(-0.72, 0.26).dy)
      ..close();
    final wing = Path()
      ..moveTo(at(-0.18, 0.14).dx, at(-0.18, 0.14).dy)
      ..lineTo(at(0.02, -0.08).dx, at(0.02, -0.08).dy)
      ..lineTo(at(0.28, 0.12).dx, at(0.28, 0.12).dy)
      ..close();
    final body = Path()
      ..moveTo(at(-0.36, 0.12).dx, at(-0.36, 0.12).dy)
      ..quadraticBezierTo(
        at(0.00, 0.28).dx,
        at(0.00, 0.28).dy,
        at(0.34, 0.16).dx,
        at(0.34, 0.16).dy,
      )
      ..quadraticBezierTo(
        at(0.10, 0.08).dx,
        at(0.10, 0.08).dy,
        at(-0.36, 0.12).dx,
        at(-0.36, 0.12).dy,
      )
      ..close();
    final beak = Path()
      ..moveTo(at(0.48, 0.07).dx, at(0.48, 0.07).dy)
      ..lineTo(at(0.66, 0.12).dx, at(0.66, 0.12).dy)
      ..lineTo(at(0.48, 0.15).dx, at(0.48, 0.15).dy)
      ..close();
    canvas
      ..drawPath(tail, white)
      ..drawPath(body, white)
      ..drawPath(wing, white)
      ..drawCircle(at(0.42, 0.09), radius * 0.09, white)
      ..drawPath(beak, white);
  }

  Path _page(Offset Function(double x, double y) at, {required bool left}) {
    final side = left ? -1.0 : 1.0;
    return Path()
      ..moveTo(at(0.045 * side, 0.36).dx, at(0.045 * side, 0.36).dy)
      ..quadraticBezierTo(
        at(0.36 * side, 0.20).dx,
        at(0.36 * side, 0.20).dy,
        at(0.68 * side, 0.28).dx,
        at(0.68 * side, 0.28).dy,
      )
      ..lineTo(at(0.68 * side, 0.58).dx, at(0.68 * side, 0.58).dy)
      ..quadraticBezierTo(
        at(0.36 * side, 0.66).dx,
        at(0.36 * side, 0.66).dy,
        at(0.045 * side, 0.70).dx,
        at(0.045 * side, 0.70).dy,
      )
      ..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
