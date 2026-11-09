# Actividad 4 — Configurar la bitácora

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 4
- **Fecha de ejecución:** 2026-11-08 19:09:33 HMM

Script `sql/02-configuracion-bitacora.sql` (psql -a: cada sentencia seguida de su resultado):

```text
-- Actividad 4 — Configurar la bitácora (recarga, no requiere reinicio)
ALTER SYSTEM SET log_connections = on;
ALTER SYSTEM
ALTER SYSTEM SET log_disconnections = on;
ALTER SYSTEM
ALTER SYSTEM SET log_line_prefix = '%m [%p] user=%u db=%d app=%a client=%h ';
ALTER SYSTEM
ALTER SYSTEM SET log_statement = 'ddl';
ALTER SYSTEM
SELECT pg_reload_conf();
 pg_reload_conf 
----------------
 t
(1 row)

-- Verificar en una consulta POSTERIOR (la recarga es asíncrona):
-- SELECT name, setting, source, sourcefile FROM pg_settings
-- WHERE name IN ('log_connections','log_line_prefix','log_statement');
```

```sql
SELECT name, setting, source, sourcefile
FROM pg_settings
WHERE name IN ('log_connections','log_line_prefix','log_statement');
```
Resultado:

```text
      name       |                 setting                 |       source       |                  sourcefile                   
-----------------+-----------------------------------------+--------------------+-----------------------------------------------
 log_connections | on                                      | configuration file | /var/lib/postgresql/data/postgresql.auto.conf
 log_line_prefix | %m [%p] user=%u db=%d app=%a client=%h  | configuration file | /var/lib/postgresql/data/postgresql.auto.conf
 log_statement   | ddl                                     | configuration file | /var/lib/postgresql/data/postgresql.auto.conf
(3 rows)

```

```sql
SELECT num, linea FROM dba.bitacora ORDER BY num DESC LIMIT 6;
```
Resultado:

```text
 num |                                                                                      linea                                                                                       
-----+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  16 | 2026-11-09 02:09:37.245 UTC [82] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  15 | 2026-11-09 02:09:37.245 UTC [82] user=[unknown] db=[unknown] app=[unknown] client=[local] LOG:  connection received: host=[local]
  14 | 2026-11-09 02:09:36.968 UTC [75] user=postgres db=comercial app=psql client=[local] LOG:  disconnection: session time: 0:00:00.002 user=postgres database=comercial host=[local]
  13 | 2026-11-09 02:09:36.966 UTC [75] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  12 | 2026-11-09 02:09:36.965 UTC [75] user=[unknown] db=[unknown] app=[unknown] client=[local] LOG:  connection received: host=[local]
  11 | 2026-11-09 02:09:33.658 UTC [1] user= db= app= client= LOG:  parameter "log_statement" changed to "ddl"
(6 rows)

```


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

- Las sentencias `ALTER SYSTEM` no aparecen porque cuando se ejecutaron `log_statement` valía `none`.
- Sí aparece `parameter ... changed to ...`, registrado por el proceso principal (PID 1) al recargar.
1. **¿Por qué lo registra el proceso principal y no tu sesión?** Porque quien relee la configuración y detecta el cambio es el proceso principal (postmaster); tu sesión solo envía la señal de recarga.
2. **Si alguien ejecuta `ALTER SYSTEM SET log_statement = 'none'`:** quedaría el cambio de parámetro (y la sentencia si el nivel vigente era ddl/mod al ejecutarla); lo que se pierde es el registro de las sentencias *posteriores*.
3. **¿Por qué no editar `postgresql.auto.conf` a mano?** Un error de sintaxis o valor inválido puede impedir el arranque o dejar cambios sin rastro; `ALTER SYSTEM` valida y deja registro.

