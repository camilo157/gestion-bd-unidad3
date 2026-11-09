# LAB Unidad III — Bitácoras y auditoría del dato en PostgreSQL

**Estudiante:** Jose Camilo Angulo Rivera
**Despliegue:** contenedor Docker `dba-u3-pg` con la imagen oficial `postgres:16` (Anexo A.1 de la guía), ejecutado en Windows
**Versión:** PostgreSQL 16.15 (Debian 16.15-1.pgdg13+2) on x86_64-pc-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit

## Cómo reproducir (Partes A y B)

Requiere Docker y Git Bash. Desde PowerShell, dentro de esta carpeta:

```powershell
$env:ESTUDIANTE = "Jose Camilo Angulo Rivera"
$env:MSYS_NO_PATHCONV = "1"
& "C:\Program Files\Git\bin\bash.exe" ./ejecutar-lab.sh
```

Si el contenedor ya existe y quieres empezar de cero, agrega antes `$env:RECREAR = "1"`.

El script genera `evidencias/*.md`, `evidencias/bitacora-lab01.log` y `evidencias/bitacora-lab01.sha256`.

## Parte C (opcional)
No realizada. Ver `sql/07-pgaudit-opcional.sql` y el Anexo A.3 de la guía.

## Contenido
- `sql/`: scripts por actividad
- `evidencias/`: salidas de ejecución, bitácora exportada con su hash y cronología
- `informe.md`: informe y reflexión