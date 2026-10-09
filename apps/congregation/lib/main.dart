import 'package:flutter/widgets.dart';
import 'package:lvm_ui/lvm_ui.dart';

void main() => runApp(
  const LvmFoundationApp(
    product: 'La Voz Misionera',
    audience: 'Para la congregación',
    plannedFeatures: [
      'Vida de la iglesia',
      'Eventos y prédicas',
      'Sedes y contacto',
    ],
  ),
);
