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
- `packages/lvm_models`: identidad de cada producto.
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
- `flutter test` sobre las ocho carpetas: 11 tests, todos pasaron.
- No hay emulador ni teléfono Android conectado. `flutter run` no se ejecutó. `flutter doctor` informa que faltan cmdline-tools y que el estado de las licencias del SDK es desconocido.
- Las cuatro APK de depuración se generaron con `flutter build apk --debug --target-platform android-arm64`. Cada una pesa 73,6 MB y queda fuera de Git, en `debug-apks/`. No son un release ni se publican. Un intento anterior con todas las ABI compiló `lvm_public` y después se quedó sin espacio en disco.
