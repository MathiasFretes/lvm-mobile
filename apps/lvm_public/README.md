# La Voz Misionera Android

Esta primera función permite abrir un archivo `PublicContent 0.1` exportado por LVM Service y consultar eventos, prédicas y sedes sin conexión. El documento válido se conserva en el dispositivo para reabrirlo; importar otro lo reemplaza completo. Un archivo inválido no sobrescribe el anterior.

El contenido es una **vista local**, no una publicación. Todavía no hay API pública, sincronización, cuenta de usuario ni CMS conectado. El botón «Quitar archivo local» borra solo esta copia del dispositivo.

El contrato fuente está en el repositorio LVM Service, `contracts/public-content-0.1.md`. La validación Flutter vive en `packages/lvm_models`; Service y Web Pública mantienen sus parsers TypeScript. Cualquier cambio de 0.1 debe verificarse en los tres consumidores antes de aceptarse.
