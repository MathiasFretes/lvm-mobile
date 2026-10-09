# LVM Mobile

Monorepo Flutter de las cuatro aplicaciones Android de La Voz Misionera. M14A.1 prepara la estructura, la identidad y la navegación inicial. No incluye autenticación, API real ni publicación.

SDK fijado: Flutter `3.47.7`, Dart `3.13.5`. El archivo [`.flutter-version`](.flutter-version) registra esa versión.

## Aplicaciones

| Carpeta | Nombre | applicationId |
| --- | --- | --- |
| `apps/lvm_public` | La Voz Misionera | `app.lavozmisionera.congregacion` |
| `apps/lvm_service` | LVM Service | `app.lavozmisionera.service` |
| `apps/lvm_worship` | LVM Worship | `app.lavozmisionera.worship` |
| `apps/lvm_presenter_remote` | LVM Presenter Remote | `app.lavozmisionera.presenterremote` |

`app.lavozmisionera.worship` no reemplaza la app React Native existente (`com.lavozmisionera.app`).

## Paquetes

- `packages/lvm_design`: Material 3, temas claro, oscuro y automático, emblema.
- `packages/lvm_models`: identidad y parsers estrictos de `PublicContent 0.1` y `Service 0.1`.
- `packages/lvm_api`: límite futuro. No hay endpoints.
- `packages/lvm_persistence`: límite futuro. El almacén incluido rechaza lecturas y escrituras.

## Comandos

Desde la raíz del repositorio, con Flutter 3.47.7 en el `PATH`:

```powershell
flutter pub get
flutter analyze
flutter test apps/lvm_public
flutter test apps/lvm_service
flutter test apps/lvm_worship
flutter test apps/lvm_presenter_remote
flutter test packages/lvm_design
flutter test packages/lvm_models
flutter test packages/lvm_api
flutter test packages/lvm_persistence
```

Ejecutar una app en un dispositivo o emulador Android:

```powershell
cd apps/lvm_public
flutter run --debug
```

Repetir el directorio para `lvm_service`, `lvm_worship` y `lvm_presenter_remote`.

APK de depuración. En esta máquina el comando general `flutter build apk --debug` no llegó a completarse: el disco se quedó sin espacio y Windows bloqueó archivos nativos temporales. La APK que sí se generó es arm64:

```powershell
cd apps/lvm_public
flutter build apk --debug --target-platform android-arm64
```

El archivo queda en `build/app/outputs/flutter-apk/app-debug.apk` de esa aplicación. No subir ese artefacto a una tienda ni a un release.

Solo Android. Este repositorio no genera proyectos iOS, macOS, web ni escritorio.

## Verificación de M14A.1

En esta máquina, Flutter 3.47.7 está en `C:\Desarrollo\flutter`. No forma parte del `PATH` global.

- `flutter analyze`: sin issues.
- `flutter test` sobre las ocho carpetas pasó en el último workflow de `main`; la app pública incorpora pruebas de importación local, contrato y vista a 390 px.
- `flutter run` en un teléfono o emulador todavía no forma parte de este gate. Las licencias Android ya están aceptadas en el entorno local.
- Las cuatro APK de depuración arm64 se generaron con `flutter build apk --debug --target-platform android-arm64` durante M14A.1 y quedaron fuera de Git. No son un release. La app pública también compiló localmente después de incorporar `PublicContent 0.1`.

CI analiza el workspace, ejecuta los tests de las ocho carpetas y construye una APK de depuración para cada aplicación. En `main` conserva durante siete días **solo la APK pública de congregación** y su SHA-256 como artefacto `lvm-public-debug-qa` para probarla en un teléfono. Las compilaciones de CI no constituyen una release. Las APK de Service y Worship no se distribuyen mientras sus productos sigan sin publicar.

`LVM Service > Cultos` puede abrir un archivo `Service 0.1` exportado desde LVM Service y mostrar su orden en el teléfono. Valida toda la estructura, conserva la última importación válida en el dispositivo y permite quitarla. Es una vista local de lectura: no edita cultos ni se conecta a la API. Un archivo inválido no reemplaza el culto ya guardado. La fixture de compatibilidad en `packages/lvm_models/test/fixtures/platform-service.json` proviene de `LVM Service/fixtures/platform-service.json`.

`LVM Worship > Repertorio` puede abrir un `WorshipContext 0.1` exportado por LVM Service, validar sus límites y conservarlo sin conexión. Este slice muestra el culto y el repertorio objetivo; todavía no edita canciones ni exporta `WorshipPlan 0.1`.
