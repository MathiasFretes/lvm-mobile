# LVM Mobile — Flutter foundation

Cuatro aplicaciones Android independientes con una identidad visual compartida:

| Carpeta | Producto | Público previsto |
| --- | --- | --- |
| `apps/congregation` | La Voz Misionera | Congregación |
| `apps/service` | LVM Service | Líderes y equipos |
| `apps/worship` | LVM Worship | Músicos |
| `apps/presenter_remote` | LVM Presenter Remote | Multimedia |

`packages/lvm_ui` define los colores y componentes básicos. Sus valores navy `#1C2A39`, dorado `#C6A15B` y fondo `#F6F7F9` corresponden a la identidad clara que ya usan Service y Web Pública. El monograma actual es una implementación Flutter sencilla; antes de distribución se debe sustituir por el asset institucional definitivo.

Esta fase crea la estructura y una pantalla honesta de desarrollo en cada app. **No hay login, conexión a API, control remoto ni APK de distribución**. La app móvil existente de Worship (Expo) permanece intacta; una eventual migración se decidirá por función.

## Desarrollo

Desde esta carpeta:

```powershell
& 'C:\Desarrollo\flutter\bin\flutter.bat' pub get
& 'C:\Desarrollo\flutter\bin\flutter.bat' analyze
& 'C:\Desarrollo\flutter\bin\flutter.bat' test packages/lvm_ui/test
```

Para ejecutar una app, entrar en su carpeta y usar `flutter run`. El repositorio usa [Pub workspaces](https://dart.dev/tools/pub/workspaces), con una sola resolución de dependencias en la raíz.

## Antes de generar APK/AAB

1. Aceptar las licencias del SDK Android en la máquina de desarrollo.
2. Definir los cuatro `applicationId` definitivos; los `com.example.*` generados por Flutter son solo para desarrollo.
3. Diseñar y verificar las funciones de cada app contra su producto dueño y sus contratos de API.
4. Implementar M9 Auth/permisos antes de conectar Service o Worship a datos privados.
5. Configurar firma de release y un canal de distribución. No publicar builds firmados con la clave de depuración.

La Web Pública actual sigue siendo una preview y Service/Worship no están autorizados para publicación. Por eso todavía no aparecen botones de descarga en esos sitios.
