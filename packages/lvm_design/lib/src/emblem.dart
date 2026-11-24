import 'package:flutter/material.dart';

/// Original LVM artwork supplied by the institution; one asset for every app.
class LvmEmblem extends StatelessWidget {
  const LvmEmblem({super.key, this.size = 112});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const Key('lvm-emblem'),
      label: 'Emblema de La Voz Misionera: libro abierto, paloma y llama',
      image: true,
      child: ExcludeSemantics(
        child: Image.asset(
          'assets/brand/lvm-circle.png',
          package: 'lvm_design',
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
