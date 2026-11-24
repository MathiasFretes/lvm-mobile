# QA físico de identidad — HONOR ELP-NX9

Fecha: 24 de noviembre de 2026. Android 16. APK fuente `f4f1c157806f19aa9255d3ec8b4284a41e72d0de` del workflow 45407649342.

## Procedencia

- APK original SHA-256: `2c940acc6bcf475b4558749c5060c3d546e8f2b7e14ad74f828e79f830999786`.
- APK instalado SHA-256: `0588a299358fd7333e0c6ea26c33e614802e3256b3a956c2fa959861367054b9`.
- Se refirmó con la clave debug local que ya firmaba la instalación previa, conservando los datos. Se compararon todas las entradas ZIP salvo META-INF: contenido sin modificaciones. La firma local no constituye firma de distribución.
- El checksum del APK instalado se verificó directamente en el dispositivo.

## Resultado observado

- Icono blanco/dorado identificado en el launcher; al tocarlo abrió la app desde un proceso detenido.
- Logo aprobado visible durante el arranque y en la cabecera de Control.
- Cinco pestañas recorridas: Control, Culto, Biblia, Canciones y Más. Nombre de marca y sección verificados en la jerarquía accesible de cada pantalla.
- Claro y Oscuro seleccionados y comprobados; se restauró la preferencia original Automático.
- La máscara exterior del launcher la controla HONOR; los recursos de icon y roundIcon contienen el sello circular aprobado.
- Capturas de las pantallas de la app guardadas junto al manifiesto. Las capturas del launcher y transición con fondo personal se mantienen privadas y no se publican.

## Alcance

QA de identidad, apertura y navegación local de Presenter Remote. La pantalla Sin conexión es el estado esperado sin Presenter emparejado. No se repitió el recorrido QR/proyección/blackout ni se certifican otras apps instaladas, Samsung A12, iOS/macOS o una distribución firmada. La prueba funcional Remote anterior conserva su alcance independiente.

Evidencias: phone-control-claro.png, phone-control-oscuro.png, phone-launch-final.png, phone-tab-checks.json, phone-theme-checks.json e installed-gold-source.json.
