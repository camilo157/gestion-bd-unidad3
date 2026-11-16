# LAB-02 — Trazabilidad en MongoDB Community

**Estudiante:** < Jose Camilo Angulo Rivera >  **Fecha:** <16/11/2026>
**Despliegue:** contenedor Docker `dba-u3-mongo` con la imagen oficial `mongo:7`, arrancado con `--auth` (Anexo A.2 de la guía), ejecutado en Windows
**Versión:** MongoDB 7.0.45 Community

## Cómo reproducir
Requiere Docker y Git Bash. Desde PowerShell, dentro de esta carpeta:

```powershell
$env:ESTUDIANTE = "Jose Camilo Angulo Rivera"$env:MSYS_NO_PATHCONV = "1"
& "C:\Program Files\Git\bin\bash.exe" ./ejecutar-lab2.sh
```

Si el contenedor ya existe y quieres empezar de cero, agrega antes `$env:RECREAR = "1"`.

El script genera `evidencias/01` a `10-*.md`, `system-profile.json`, `bitacora-mongod.log` y `hashes.sha256`.

## Contenido
- `scripts/comandos-mongosh.js`: comandos de referencia por actividad
- `evidencias/`: salidas de ejecución, exportaciones y hashes
- `informe.md`: informe y reflexión

## Limitación principal
MongoDB Community Edition **no** incluye auditoría nativa (solo Enterprise y Atlas M10+). Este laboratorio usa el perfilador, la bitácora de `mongod` y un control compensatorio, y documenta lo que no puede demostrarse.
