import 'package:flutter/widgets.dart';
import 'package:lvm_ui/lvm_ui.dart';

void main() => runApp(
  const LvmFoundationApp(
    product: 'LVM Presenter Remote',
    audience: 'Para el equipo multimedia',
    plannedFeatures: [
      'Control de presentación',
      'Vista previa de diapositivas',
      'Estado de salida',
    ],
  ),
);
