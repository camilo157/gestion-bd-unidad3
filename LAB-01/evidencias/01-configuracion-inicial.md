# Actividad 1 — Configuración de registro por defecto

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 1
- **Fecha de ejecución:** 2026-11-08 19:09:22 HMM

```sql
SELECT name, setting, source
FROM pg_settings
WHERE name IN ('log_destination','logging_collector','log_directory','log_filename',
               'log_connections','log_disconnections','log_line_prefix',
               'log_statement','log_min_error_statement','log_timezone')
ORDER BY name;
```
Resultado:

```text
          name           |            setting             |       source       
-------------------------+--------------------------------+--------------------
 log_connections         | off                            | default
 log_destination         | stderr                         | default
 log_directory           | log                            | default
 log_disconnections      | off                            | default
 log_filename            | postgresql-%Y-%m-%d_%H%M%S.log | default
 logging_collector       | off                            | default
 log_line_prefix         | %m [%p]                        | default
 log_min_error_statement | error                          | default
 log_statement           | none                           | default
 log_timezone            | Etc/UTC                        | configuration file
(10 rows)

```


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **¿Se registra quién se conecta?** No: `log_connections = off`.
2. **¿Se registran los UPDATE?** No: `log_statement = none`.
3. **¿La línea incluye usuario o IP?** No: el prefijo por defecto es solo `%m [%p]` (hora y PID).
4. **Zona horaria:** la de `log_timezone` (en la guía, UTC). Importa porque para correlacionar bitácora, auditoría y otros sistemas todas las marcas de tiempo deben compartir referencia horaria.
5. **Con `logging_collector = off`** decide el mecanismo de despliegue (script de arranque, systemd, Docker), no PostgreSQL.

