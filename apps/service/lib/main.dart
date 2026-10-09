import 'package:flutter/widgets.dart';
import 'package:lvm_ui/lvm_ui.dart';

void main() => runApp(
  const LvmFoundationApp(
    product: 'LVM Service',
    audience: 'Para líderes y equipos',
    plannedFeatures: [
      'Planificación de cultos',
      'Coordinación de equipos',
      'Contenido público',
    ],
  ),
);
