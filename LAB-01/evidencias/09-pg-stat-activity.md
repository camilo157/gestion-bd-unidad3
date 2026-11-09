# Actividad 9 — Sesiones activas con pg_stat_activity

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 9
- **Fecha de ejecución:** 2026-11-08 19:09:49 HMM


Sesión de larga duración: `SELECT pg_sleep(20)` como soporte_ana con application_name=reporte-mensual (la guía usa 90 s). PID observado: **194**.


### Mientras se ejecuta

```sql
SELECT pid, usename, application_name, client_addr, backend_start, state, left(query, 30) AS query
FROM pg_stat_activity WHERE backend_type = 'client backend';
```
Resultado:

```text
 pid |   usename   | application_name | client_addr |         backend_start         | state  |             query              
-----+-------------+------------------+-------------+-------------------------------+--------+--------------------------------
 208 | postgres    | psql             |             | 2026-11-09 02:09:54.425059+00 | active | SELECT pid, usename, applicati
 194 | soporte_ana | reporte-mensual  | 127.0.0.1   | 2026-11-09 02:09:50.102823+00 | active | SELECT pg_sleep(20)
(2 rows)

```

```sql
SELECT linea FROM dba.bitacora WHERE linea LIKE '%[194]%' ORDER BY num;
```
Resultado:

```text
                                                                                                         linea                                                                                                         
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 2026-11-09 02:09:50.102 UTC [194] user=[unknown] db=[unknown] app=[unknown] client=127.0.0.1 LOG:  connection received: host=127.0.0.1 port=45364
 2026-11-09 02:09:50.110 UTC [194] user=soporte_ana db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authenticated: identity="soporte_ana" method=scram-sha-256 (/var/lib/postgresql/data/pg_hba.conf:119)
 2026-11-09 02:09:50.110 UTC [194] user=soporte_ana db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authorized: user=soporte_ana database=comercial application_name=reporte-mensual
(3 rows)

```


### Después de que termina el reporte

```sql
SELECT pid, usename, application_name, client_addr, backend_start, state, left(query, 30) AS query
FROM pg_stat_activity WHERE backend_type = 'client backend';
```
Resultado:

```text
 pid | usename  | application_name | client_addr |         backend_start         | state  |             query              
-----+----------+------------------+-------------+-------------------------------+--------+--------------------------------
 223 | postgres | psql             |             | 2026-11-09 02:10:12.456169+00 | active | SELECT pid, usename, applicati
(1 row)

```

```sql
SELECT linea FROM dba.bitacora WHERE linea LIKE '%[194]%' ORDER BY num;
```
Resultado:

```text
                                                                                                         linea                                                                                                         
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 2026-11-09 02:09:50.102 UTC [194] user=[unknown] db=[unknown] app=[unknown] client=127.0.0.1 LOG:  connection received: host=127.0.0.1 port=45364
 2026-11-09 02:09:50.110 UTC [194] user=soporte_ana db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authenticated: identity="soporte_ana" method=scram-sha-256 (/var/lib/postgresql/data/pg_hba.conf:119)
 2026-11-09 02:09:50.110 UTC [194] user=soporte_ana db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authorized: user=soporte_ana database=comercial application_name=reporte-mensual
 2026-11-09 02:10:10.130 UTC [194] user=soporte_ana db=comercial app=reporte-mensual client=127.0.0.1 LOG:  disconnection: session time: 0:00:20.027 user=soporte_ana database=comercial host=127.0.0.1 port=45364
(4 rows)

```


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **Columna que relaciona sesión y bitácora:** `pid` (aparece como `[pid]` en cada línea).
2. **Después de terminar el reporte:** solo la bitácora conserva evidencia de que existió; `pg_stat_activity` muestra únicamente sesiones vivas (fotografía, no historia).
3. **`client_addr` vacío en el administrador:** se conectó por socket Unix local, sin dirección IP.

