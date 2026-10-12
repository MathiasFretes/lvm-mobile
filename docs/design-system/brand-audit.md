# Auditoría de identidad institucional

Estado: borrador de M14A.2.1. No sustituye assets. No aprueba un logo.

Baseline: `origin/main` `e95a131ae3bcacbd091bce3bed07760e8dc131c8`.
Issue: [#10](https://github.com/MathiasFretes/lvm-mobile/issues/10).

El sello exigido por la dirección tiene tres elementos: libro abierto, paloma y llama, en blanco sobre un círculo azul marino. Esta auditoría busca una fuente gráfica comprobable. No inventa otra iconografía.

## Veredicto

**Bloqueo de assets.** No hay un SVG ni un PNG maestro del sello institucional en los lugares revisados. Ningún candidato puede declararse fuente oficial. M14A.2.2 no debe reemplazar el emblema provisional hasta que la dirección entregue ese original y lo confirme.

No se copió ningún archivo de Worship ni de otros productos a este repositorio.

## Inventario

Los recursos de Worship se leyeron en `C:\la-voz-misionera\LVM Worship` y no se modificaron. Son candidatos, no una fuente asumida.

| Recurso | Formato | Qué es | Fondo | Procedencia conocida | Veredicto |
| --- | --- | --- | --- | --- | --- |
| `packages/lvm_design/lib/src/emblem.dart` | `CustomPainter` | Círculo `#0B2345` con una llama, una silueta de paloma y dos rectángulos redondeados como páginas. Tamaño por defecto 112. La etiqueta accesible nombra libro, paloma y llama. | Círculo opaco, sin transparencia | Dibujo geométrico escrito para las apps Flutter. Autoría: el propio monorepo. No proviene de un trazado institucional. | Provisional. No es fuente oficial. |
| `apps/*/android/app/src/main/res/drawable/ic_lvm_emblem.xml` | Vector drawable 108×108 dp | Círculo navy y formas blancas de llama, paloma (cola, cuerpo, ala, pico) y dos páginas curvas. Los cuatro archivos son idénticos byte a byte. Cada `AndroidManifest.xml` lo usa como `android:icon`. No hay icono adaptable (`mipmap` con primer plano y fondo). | Círculo opaco | Misma intención que el painter, otro dibujo. No es una exportación del `CustomPainter`. | Provisional. No es fuente oficial. |
| `NEW ASSETS/icon.png` | PNG 1024×1024, 24 bpp, 48994 bytes, sin canal alfa | Monograma de dos arcos, uno celeste y uno claro, sobre fondo casi negro. No contiene libro, paloma ni llama. | Opaco, sin transparencia | Candidato citado por el issue #10. No hay titularidad institucional registrada en el archivo. | Descartado. No es el sello de La Voz Misionera. |
| `NEW ASSETS/lvm-light.svg` | Ausente | El script `apps/web/scripts/generate-favicons.mjs` lo nombra como maestro de la marca «Signal Blue». | — | Referencia rota en el árbol local. | Ausente. No puede usarse. |
| `NEW ASSETS/gc-light.svg` | SVG con trazos de letras, colores `#1e2227` y `#1f84c9`, fondo `#f5f7f9` | Wordmark ajeno al sello. Es el único archivo presente en `NEW ASSETS` junto con `icon.png`. | Fondo claro opaco | Carpeta de assets de Worship. Sin acta de aprobación como sello LVM. | Descartado. |
| `apps/web/public/lvm-mark.svg` | SVG 1024×1024 | Monograma de las letras LVM más ondas. Paleta `#123458`, `#071522` y cian `#53D8FF`. El título interno dice «La Voz Misionera». | Rectángulo redondeado opaco | Marca web de Worship, no el sello de libro, paloma y llama. | Descartado. |
| `apps/web/public/icons/v2/favicon.svg` | SVG 512×512 que incrusta otro SVG | Derivado del maestro ausente `lvm-light.svg`. Recorta esquinas redondeadas. Paleta de letras `#1e2227` y `#1f84c9`. | Claro | Generado para favicon. El script lo describe como Signal Blue, no como el sello institucional. | Descartado. |
| `apps/mobile/assets/lvm-mark.svg` | SVG 1024×1024 | Cruz blanca dentro de un círculo `#C6A15B` sobre un rectángulo navy. La descripción interna lo dice así. No es el mismo archivo que el `lvm-mark.svg` de la web. | Rectángulo redondeado opaco | Asset de la app React Native de Worship. | Descartado. |

## Comparación con el sello exigido

| Elemento exigido | Emblema Flutter | Vector Android | Candidatos de Worship |
| --- | --- | --- | --- |
| Libro abierto | Dos rectángulos redondeados, no páginas de un libro trazado | Dos páginas curvas, todavía geométricas | Ausente |
| Paloma | Una sola silueta cerrada | Silueta con cola, ala, cuerpo y pico | Ausente |
| Llama | Tres curvas sobre el círculo | Una llama más articulada | Ausente |
| Blanco sobre círculo navy | Sí, `#0B2345` y blanco | Sí, `#0B2345` y blanco | No. Usan cian, oro, letras o un monograma ajeno |

El painter y el vector Android comparten la idea y la paleta, y no el trazo. A 24 px el painter se reduce a tres manchas blancas. Eso no se corrige redibujándolo otra vez a mano.

## Decisiones pendientes

1. La dirección debe entregar el maestro SVG o PNG del sello aprobado, con libro abierto, paloma y llama, y confirmar que esa pieza es la fuente oficial.
2. Recién entonces M14A.2.2 puede preparar la versión blanca sobre círculo navy, las variantes claro y oscuro, y los iconos Android de las cuatro apps.
3. Hasta esa confirmación, `emblem.dart` y `ic_lvm_emblem.xml` siguen como están.

## Riesgos

- Tratar `icon.png`, `lvm-mark.svg` o el favicon como sello oficial cambiaría la identidad por una marca distinta.
- Copiar esos archivos a `lvm-mobile` sin licencia y sin visto bueno metería material no autorizado en el repositorio.
- Sustituir el emblema provisional por otro dibujo inventado cerraría el gate visual sin el original.

## Qué no se hizo

No hay previews nuevos. No se reemplazó el logo. No se modificó ninguna app, contrato ni persistencia.
