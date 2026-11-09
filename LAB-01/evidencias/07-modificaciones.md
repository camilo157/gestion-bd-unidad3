# Actividad 7 — ddl frente a mod

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 7
- **Fecha de ejecución:** 2026-11-08 19:09:41 HMM


### Con log_statement = 'ddl'

```bash
psql "postgresql://app_ventas:<REDACTED>@127.0.0.1/comercial?application_name=app-ventas-web" -c "UPDATE clientes SET rfc = 'GAMA780912XYZ' WHERE id = 3"
```
Resultado:

```text
UPDATE 1
```

```sql
SELECT linea FROM dba.bitacora WHERE linea LIKE '%user=app_ventas%' ORDER BY num DESC LIMIT 3;
```
Resultado:

```text
                                                                                                        linea                                                                                                        
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 2026-11-09 02:09:41.641 UTC [138] user=app_ventas db=comercial app=app-ventas-web client=127.0.0.1 LOG:  disconnection: session time: 0:00:00.013 user=app_ventas database=comercial host=127.0.0.1 port=57130
 2026-11-09 02:09:41.638 UTC [138] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authorized: user=app_ventas database=comercial application_name=app-ventas-web
 2026-11-09 02:09:41.638 UTC [138] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authenticated: identity="app_ventas" method=scram-sha-256 (/var/lib/postgresql/data/pg_hba.conf:119)
(3 rows)

```


### Cambio a log_statement = 'mod'

```sql
ALTER SYSTEM SET log_statement = 'mod';
SELECT pg_reload_conf();
```
Resultado:

```text
ALTER SYSTEM
 pg_reload_conf 
----------------
 t
(1 row)

```

```bash
psql "postgresql://app_ventas:<REDACTED>@127.0.0.1/comercial?application_name=app-ventas-web" -c "UPDATE clientes SET telefono = '6679990000' WHERE id = 3" -c "SELECT nombre, rfc FROM clientes WHERE id = 3"
```
Resultado:

```text
UPDATE 1
    nombre    |      rfc      
--------------+---------------
 María García | GAMA780912XYZ
(1 row)

```

```sql
SELECT linea FROM dba.bitacora
WHERE linea LIKE '%log_statement%' OR linea LIKE '%user=app_ventas%statement:%'
ORDER BY num;
```
Resultado:

```text
                                                                                    linea                                                                                     
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 2026-11-09 02:09:33.658 UTC [1] user= db= app= client= LOG:  parameter "log_statement" changed to "ddl"
 2026-11-09 02:09:43.241 UTC [152] user=postgres db=comercial app=psql client=[local] LOG:  statement: ALTER SYSTEM SET log_statement = 'mod';
 2026-11-09 02:09:43.247 UTC [1] user= db= app= client= LOG:  parameter "log_statement" changed to "mod"
 2026-11-09 02:09:46.548 UTC [159] user=app_ventas db=comercial app=app-ventas-web client=127.0.0.1 LOG:  statement: UPDATE clientes SET telefono = '6679990000' WHERE id = 3
(4 rows)

```


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

- Con `ddl` aparecen conexión y desconexión de `app_ventas`, pero no el UPDATE.
- Con `mod` aparece quién, cuándo, desde dónde, qué aplicación y qué sentencia. El SELECT del RFC no aparece. Tampoco aparece el valor anterior del teléfono.
1. **¿Qué nivel habría registrado la lectura del RFC?** `all`. En un servidor con miles de consultas por minuto el costo sería enorme en volumen, almacenamiento, rendimiento y datos sensibles dentro de la bitácora.
2. **¿Qué le falta para revertir con certeza?** El valor anterior del dato: la bitácora muestra qué se escribió, no qué había antes (se resuelve con la tabla de auditoría de la Parte B).

