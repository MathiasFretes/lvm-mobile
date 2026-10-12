# Especificación visual compartida — borrador

Estado: propuesta de M14A.2.1. No implementa componentes ni cambia pantallas.
Baseline: `origin/main` `e95a131ae3bcacbd091bce3bed07760e8dc131c8`.

Las cuatro apps deben compartir fundamentos de marca y conservar experiencias distintas. Congregación, Service, Worship y Presenter Remote no se redibujan en este documento. El logo oficial sigue bloqueado en [brand-audit.md](brand-audit.md). Esta especificación no lo aprueba.

## Tokens que ya existen

Definidos en `packages/lvm_design/lib/src/colors.dart` y aplicados en `theme.dart`.

| Token | Valor | Uso actual |
| --- | --- | --- |
| Navy | `#0B2345` | Primario en claro. Superficie y texto sobre oro en oscuro. Barra superior en ambos temas. Círculo del emblema. |
| Gold | `#D4A853` | Secundario en claro. Primario en oscuro. Indicador de la navegación al 45 % de opacidad. |
| Neutral | `#F4F5F8` | Superficie y fondo de claro. Texto sobre oscuro. |
| Blanco | `#FFFFFF` | Texto sobre navy en claro. Fondo de la barra de navegación en claro. |
| Navy profundo | `#071628` | Fondo de la pantalla en oscuro. |

`ColorScheme.fromSeed` sigue generando el resto de los roles de Material a partir de navy. Los roles que el tema no pisa pueden apartarse de la paleta institucional. La propuesta es fijar, cuando se implemente, superficie, texto, borde, error, acción y estado deshabilitado con tokens propios, sin dejar el seed como única fuente.

## Tipografía

Hoy no hay `fontFamily`. El texto usa la fuente de la plataforma y los estilos de Material 3 (`headlineMedium`, `titleLarge`, `bodyLarge`, `labelLarge`). La navegación fija las etiquetas en 12 px, peso 700 si están seleccionadas y 500 si no.

Poppins queda como candidata solo si la dirección aporta el archivo y una licencia que permita distribuirlo en las APK. Hasta ese visto bueno se mantiene la tipografía de plataforma. Este PR no agrega archivos de fuente.

Escala propuesta para la etapa de componentes, todavía sin código:

| Rol | Tamaño | Peso |
| --- | --- | --- |
| Título de pantalla | 28 | 600 |
| Título de sección | 22 | 600 |
| Título de tarjeta | 20 | 600 |
| Cuerpo | 16 | 400 |
| Etiqueta | 14 | 500 |
| Meta y navegación | 12 | 500 o 700 |

La altura de línea del cuerpo debe permitir texto aumentado de Android sin recortar.

## Espaciado, radio y estados

Los valores están escritos en cada pantalla, no en un token.

- El shell usa `EdgeInsets.all(24)` en Inicio, secciones y Apariencia.
- Repertorio de Worship, la vista local de Service y el contenido público usan `20`.
- Una tarjeta de contenido público usa `16`.
- El emblema mide 112 por defecto. Entre el emblema y el título hay 24.

Propuesta de escala: 4, 8, 12, 16, 20, 24, 32. Un solo ritmo para las cuatro apps. Radio de tarjeta 16, radio de botón lleno 28, radio de campo 12. Esos números se confirman al construir los componentes; aquí no se aplican.

Estados a cubrir en M14A.2.3: habilitado, presionado, deshabilitado, error, vacío y carga. El error usa hoy `colorScheme.error` sobre un `Text` suelto. La carga de Worship es un `LinearProgressIndicator`. No hay un vacío ni un error compartidos.

## Navegación y temas

`LvmAppShell` muestra una barra superior navy, alineada a la izquierda, y una `NavigationBar` de tres destinos como máximo en las apps actuales: Inicio, la sección de producto y Apariencia. El indicador es oro translúcido. Cada app elige sus iconos y páginas. No se propone una navegación idéntica.

Temas en `LvmThemeController`: claro, oscuro y automático (`ThemeMode.system`). La preferencia vive en memoria. Al cerrar la app vuelve a automático. M14A.2.3 puede guardarla en una preferencia propia, distinta de `lvm.worship.context.0.1`, de Service y de Congregación. Este borrador no agrega esa persistencia.

Anchos de referencia para la revisión posterior: 360, 390 y 412 dp, más texto aumentado. El corte de «Automático» ya aparece en el ancho del ELP NX9.

## Componentes previstos

Se consolidarían en `lvm_design` en M14A.2.3, no en este PR:

- `LvmButton`: principal, secundario, texto y destructivo.
- `LvmCard`: contenedor de información.
- `LvmTextField`: campo y validación.
- `LvmEmptyState` y `LvmErrorState`.
- `LvmLoading`.
- `LvmAppShell`, ya existente, sin reescribirlo.
- `LvmSectionHeader`.
- `LvmDialog` para confirmaciones.

Cada componente debe aceptar el contenido de la app y funcionar en claro, oscuro y automático.

## Diferido al issue #9

Esta sección no forma parte de la auditoría del sello y no se implementa aquí. Las correcciones corresponden a M14A.2.3 y al [issue #9](https://github.com/MathiasFretes/lvm-mobile/issues/9). No cambian `WorshipContext 0.1`, el parser ni la persistencia.

### «Automático» se parte

Causa: `LvmAppearancePage` arma un `SegmentedButton` de tres segmentos. Cada uno lleva icono y texto. «Automático» es la etiqueta más larga y, con el icono, no cabe en un tercio de la pantalla. El control no reserva una segunda línea con altura suficiente, así que el glifo corta la palabra en «Automá» y «tico».

Alcance: las cuatro apps usan esta página.

Propuesta para después: dar al segmento ancho y alto para la palabra completa, o mostrar el icono con la etiqueta accesible «Automático» si el texto no cabe. No acortar el significado. Verificar en 360 dp y con el texto de Android agrandado, en los tres temas.

### El mensaje de contrato deja «0.1.» solo

Causa: `WorshipContextController.importJson` asigna la frase exacta «El archivo no cumple el contrato WorshipContext 0.1.». `WorshipContextPage` la pinta en un `Text` con el color de error. `WorshipContext` es una sola palabra, así que el salto cae antes de «0.1.» cuando el ancho, ya restado el relleno de 20, no alcanza.

La misma pauta existe en Service («Service 0.1.») y en Congregación («PublicContent 0.1.»).

Propuesta para después: un bloque de error que corte por palabras y pueda partir el identificador del contrato sin cambiar el texto ni el parser. El mensaje completo debe seguir siendo legible en claro y en oscuro.

### Inicio dice que la app no guarda datos

Causa: `LvmIdentityPage` escribe, para las cuatro apps, «Esta aplicación todavía no consulta servicios ni guarda datos.». Worship sí conserva el contexto en `lvm.worship.context.0.1`. Service y Congregación también guardan su documento local. Presenter Remote todavía no.

Propuesta para después: un texto propio por producto. En Worship, decir que el culto importado queda en el dispositivo y que no hay sincronización. No mencionar API ni Auth. No usar la misma frase para una app que aún no guarda nada y para una que sí guarda.

## Fuera de este borrador

No se reemplaza el emblema. No se publican APK. No entran canciones, WorshipPlan, Presenter Remote ni trabajo para Apple.
