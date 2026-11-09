# Actividad 2 — Colector de bitácora y vista dba.bitacora

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 2
- **Fecha de ejecución:** 2026-11-08 19:09:22 HMM

```sql
ALTER SYSTEM SET logging_collector = on;
SELECT name, setting, pending_restart FROM pg_settings WHERE name = 'logging_collector';
```
Resultado:

```text
ALTER SYSTEM
       name        | setting | pending_restart 
-------------------+---------+-----------------
 logging_collector | off     | f
(1 row)

```


Reinicio del servicio: `docker restart dba-u3-pg`

Script `sql/01-colector-y-vista.sql` (psql -a: cada sentencia seguida de su resultado):

```text
-- Actividad 2 — Colector de bitácora propio del servidor y vista dba.bitacora
ALTER SYSTEM SET logging_collector = on;
ALTER SYSTEM
SELECT name, setting, pending_restart FROM pg_settings WHERE name = 'logging_collector';
       name        | setting | pending_restart 
-------------------+---------+-----------------
 logging_collector | on      | f
(1 row)

-- >>> REINICIAR EL SERVICIO AQUÍ (docker restart dba-u3-pg) y abrir sesión nueva <<<
SELECT name, setting, source FROM pg_settings WHERE name = 'logging_collector';
       name        | setting |       source       
-------------------+---------+--------------------
 logging_collector | on      | configuration file
(1 row)

SELECT pg_current_logfile();
          pg_current_logfile          
--------------------------------------
 log/postgresql-2026-11-09_020923.log
(1 row)

SELECT linea
FROM regexp_split_to_table(pg_read_file(pg_current_logfile()), E'\n') AS linea;
                                                                                linea                                                                                
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
 2026-11-09 02:09:23.883 UTC [1] LOG:  starting PostgreSQL 16.15 (Debian 16.15-1.pgdg13+2) on x86_64-pc-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit
 2026-11-09 02:09:23.884 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
 2026-11-09 02:09:23.884 UTC [1] LOG:  listening on IPv6 address "::", port 5432
 2026-11-09 02:09:23.887 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
 2026-11-09 02:09:23.892 UTC [30] LOG:  database system was shut down at 2026-11-09 02:09:23 UTC
 2026-11-09 02:09:23.897 UTC [1] LOG:  database system is ready to accept connections
 
(7 rows)

CREATE SCHEMA dba;
CREATE SCHEMA
REVOKE ALL ON SCHEMA dba FROM PUBLIC;
REVOKE
CREATE VIEW dba.bitacora AS
SELECT t.n AS num, t.linea
FROM regexp_split_to_table(pg_read_file(pg_current_logfile()), E'\n')
     WITH ORDINALITY AS t(linea, n)
WHERE t.linea <> '';
CREATE VIEW
SELECT num, linea FROM dba.bitacora ORDER BY num DESC LIMIT 10;
 num |                                                                                linea                                                                                
-----+---------------------------------------------------------------------------------------------------------------------------------------------------------------------
   6 | 2026-11-09 02:09:23.897 UTC [1] LOG:  database system is ready to accept connections
   5 | 2026-11-09 02:09:23.892 UTC [30] LOG:  database system was shut down at 2026-11-09 02:09:23 UTC
   4 | 2026-11-09 02:09:23.887 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
   3 | 2026-11-09 02:09:23.884 UTC [1] LOG:  listening on IPv6 address "::", port 5432
   2 | 2026-11-09 02:09:23.884 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
   1 | 2026-11-09 02:09:23.883 UTC [1] LOG:  starting PostgreSQL 16.15 (Debian 16.15-1.pgdg13+2) on x86_64-pc-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit
(6 rows)

SELECT linea FROM dba.bitacora WHERE linea ILIKE '%update%';
 linea 
-------
(0 rows)

SELECT linea FROM dba.bitacora WHERE linea ~ '(FATAL|ERROR)';
 linea 
-------
(0 rows)

SELECT * FROM pg_ls_logdir();
               name               | size |      modification      
----------------------------------+------+------------------------
 postgresql-2026-11-09_020923.log |  609 | 2026-11-09 02:09:23+00
(1 row)

```


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **¿Por qué `logging_collector` requiere reinicio y `log_statement` solo recarga?** El colector es un proceso que el servidor lanza al arrancar; `log_statement` es solo un valor que cada sesión consulta, así que basta releer la configuración.
2. **Ventaja de leer la bitácora con SQL:** funciona igual en cualquier despliegue y se puede filtrar con SQL/regex. **Riesgo:** quien pueda leer `dba.bitacora` (o usar `pg_read_file`) ve todo el archivo, incluidos secretos y datos personales, y `pg_read_file` puede leer otros archivos del servidor.
3. **¿Quién debería consultarla?** Solo el DBA o un rol de custodia/auditoría autorizado; nunca la aplicación ni los analistas (por eso `REVOKE ALL ... FROM PUBLIC`).

