import 'package:flutter/material.dart';

import 'emblem.dart';

abstract final class LvmBrandTokens {
  static const double emblem = 40;
  static const double gap = 12;
  static const double name = 15;
  static const double product = 12;
}

class LvmBrandIdentity extends StatelessWidget {
  const LvmBrandIdentity({super.key, required this.product});

  final String product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const LvmEmblem(size: LvmBrandTokens.emblem),
        const SizedBox(width: LvmBrandTokens.gap),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'La Voz Misionera',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: LvmBrandTokens.name,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                product,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: LvmBrandTokens.product),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
