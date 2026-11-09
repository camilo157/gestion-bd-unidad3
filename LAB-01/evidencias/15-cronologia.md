# Actividad 17 — Cronología y respuestas a Dirección

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 17
- **Fecha de ejecución:** 2026-11-08 19:10:20 HMM


Material base extraído de la bitácora y de la tabla de auditoría (úsalo para armar tu tabla; **la cronología y la interpretación son tuyas**).

```sql
SELECT num, left(linea, 230) AS linea
FROM dba.bitacora
WHERE linea ~ '(parameter|connection authorized|FATAL|ERROR|statement:)'
ORDER BY num;
```
Resultado:

```text
 num |                                                                                              linea                                                                                               
-----+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   8 | 2026-11-09 02:09:33.657 UTC [1] LOG:  parameter "log_connections" changed to "on"
   9 | 2026-11-09 02:09:33.657 UTC [1] LOG:  parameter "log_disconnections" changed to "on"
  10 | 2026-11-09 02:09:33.658 UTC [1] user= db= app= client= LOG:  parameter "log_line_prefix" changed to "%m [%p] user=%u db=%d app=%a client=%h "
  11 | 2026-11-09 02:09:33.658 UTC [1] user= db= app= client= LOG:  parameter "log_statement" changed to "ddl"
  13 | 2026-11-09 02:09:36.966 UTC [75] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  16 | 2026-11-09 02:09:37.245 UTC [82] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  19 | 2026-11-09 02:09:37.542 UTC [89] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 FATAL:  password authentication failed for user "app_ventas"
  22 | 2026-11-09 02:09:37.797 UTC [96] user=usuario_inexistente db=comercial app=[unknown] client=127.0.0.1 FATAL:  password authentication failed for user "usuario_inexistente"
  27 | 2026-11-09 02:09:38.055 UTC [103] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authorized: user=app_ventas database=comercial application_name=app-ventas-web
  30 | 2026-11-09 02:09:39.383 UTC [110] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  33 | 2026-11-09 02:09:39.671 UTC [117] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  36 | 2026-11-09 02:09:39.998 UTC [124] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  37 | 2026-11-09 02:09:39.999 UTC [124] user=postgres db=comercial app=psql client=[local] LOG:  statement: REVOKE UPDATE ON clientes FROM soporte_ana;
  38 | 2026-11-09 02:09:40.001 UTC [124] user=postgres db=comercial app=psql client=[local] LOG:  statement: GRANT UPDATE ON clientes TO app_ventas;
  39 | 2026-11-09 02:09:40.002 UTC [124] user=postgres db=comercial app=psql client=[local] LOG:  statement: ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20);
  40 | 2026-11-09 02:09:40.003 UTC [124] user=postgres db=comercial app=psql client=[local] LOG:  statement: CREATE ROLE rol_temporal LOGIN PASSWORD 'Temporal_Practica_2026';
  41 | 2026-11-09 02:09:40.010 UTC [124] user=postgres db=comercial app=psql client=[local] LOG:  statement: DROP ROLE rol_temporal;
  44 | 2026-11-09 02:09:41.335 UTC [131] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  48 | 2026-11-09 02:09:41.638 UTC [138] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authorized: user=app_ventas database=comercial application_name=app-ventas-web
  51 | 2026-11-09 02:09:42.959 UTC [145] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  54 | 2026-11-09 02:09:43.240 UTC [152] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  55 | 2026-11-09 02:09:43.241 UTC [152] user=postgres db=comercial app=psql client=[local] LOG:  statement: ALTER SYSTEM SET log_statement = 'mod';
  58 | 2026-11-09 02:09:43.247 UTC [1] user= db= app= client= LOG:  parameter "log_statement" changed to "mod"
  61 | 2026-11-09 02:09:46.547 UTC [159] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authorized: user=app_ventas database=comercial application_name=app-ventas-web
  62 | 2026-11-09 02:09:46.548 UTC [159] user=app_ventas db=comercial app=app-ventas-web client=127.0.0.1 LOG:  statement: UPDATE clientes SET telefono = '6679990000' WHERE id = 3
  65 | 2026-11-09 02:09:47.884 UTC [166] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  69 | 2026-11-09 02:09:48.200 UTC [173] user=soporte_ana db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authorized: user=soporte_ana database=comercial application_name=psql
  70 | 2026-11-09 02:09:48.200 UTC [173] user=soporte_ana db=comercial app=psql client=127.0.0.1 LOG:  statement: DELETE FROM clientes WHERE id = 5
  71 | 2026-11-09 02:09:48.201 UTC [173] user=soporte_ana db=comercial app=psql client=127.0.0.1 ERROR:  permission denied for table clientes
  75 | 2026-11-09 02:09:48.480 UTC [180] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  76 | 2026-11-09 02:09:48.482 UTC [180] user=postgres db=comercial app=psql client=[local] LOG:  statement: DROP ROLE soporte_ana;
  77 | 2026-11-09 02:09:48.482 UTC [180] user=postgres db=comercial app=psql client=[local] ERROR:  role "soporte_ana" cannot be dropped because some objects depend on it
  82 | 2026-11-09 02:09:49.798 UTC [187] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  86 | 2026-11-09 02:09:50.110 UTC [194] user=soporte_ana db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authorized: user=soporte_ana database=comercial application_name=reporte-mensual
  88 | 2026-11-09 02:09:54.152 UTC [201] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  91 | 2026-11-09 02:09:54.425 UTC [208] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  94 | 2026-11-09 02:09:54.697 UTC [215] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
  98 | 2026-11-09 02:10:12.456 UTC [223] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
 101 | 2026-11-09 02:10:12.738 UTC [230] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
 104 | 2026-11-09 02:10:13.040 UTC [237] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
 105 | 2026-11-09 02:10:13.041 UTC [237] user=postgres db=comercial app=psql client=[local] LOG:  statement: CREATE SCHEMA auditoria;
 106 | 2026-11-09 02:10:13.043 UTC [237] user=postgres db=comercial app=psql client=[local] LOG:  statement: REVOKE ALL ON SCHEMA auditoria FROM PUBLIC;
 107 | 2026-11-09 02:10:13.044 UTC [237] user=postgres db=comercial app=psql client=[local] LOG:  statement: CREATE TABLE auditoria.cambios_clientes (
 121 | 2026-11-09 02:10:13.344 UTC [244] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
 122 | 2026-11-09 02:10:13.345 UTC [244] user=postgres db=comercial app=psql client=[local] LOG:  statement: CREATE OR REPLACE FUNCTION auditoria.registrar_cambio_cliente()
 145 | 2026-11-09 02:10:13.347 UTC [244] user=postgres db=comercial app=psql client=[local] LOG:  statement: REVOKE ALL ON FUNCTION auditoria.registrar_cambio_cliente() FROM PUBLIC;
 146 | 2026-11-09 02:10:13.348 UTC [244] user=postgres db=comercial app=psql client=[local] LOG:  statement: CREATE TRIGGER trg_auditoria_clientes
 151 | 2026-11-09 02:10:14.651 UTC [251] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
 155 | 2026-11-09 02:10:14.953 UTC [258] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authorized: user=app_ventas database=comercial application_name=app-ventas-web
 156 | 2026-11-09 02:10:14.954 UTC [258] user=app_ventas db=comercial app=app-ventas-web client=127.0.0.1 LOG:  statement: UPDATE clientes SET rfc = 'GAMA780912ZZZ' WHERE id = 3
 160 | 2026-11-09 02:10:15.217 UTC [265] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authorized: user=app_ventas database=comercial application_name=psql
 161 | 2026-11-09 02:10:15.218 UTC [265] user=app_ventas db=comercial app=psql client=127.0.0.1 ERROR:  permission denied for schema auditoria at character 15
 165 | 2026-11-09 02:10:15.502 UTC [272] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
 168 | 2026-11-09 02:10:15.745 UTC [279] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
 171 | 2026-11-09 02:10:16.074 UTC [286] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
 172 | 2026-11-09 02:10:16.075 UTC [286] user=postgres db=comercial app=psql client=[local] LOG:  statement: INSERT INTO clientes (nombre, correo, rfc, edad, ciudad, codigo_postal)
 174 | 2026-11-09 02:10:16.077 UTC [286] user=postgres db=comercial app=psql client=[local] LOG:  statement: DELETE FROM clientes WHERE nombre = 'Pedro Ruiz';
 178 | 2026-11-09 02:10:16.383 UTC [293] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authorized: user=app_ventas database=comercial application_name=app-ventas-web
 179 | 2026-11-09 02:10:16.384 UTC [293] user=app_ventas db=comercial app=app-ventas-web client=127.0.0.1 LOG:  statement: DELETE FROM auditoria.cambios_clientes
 180 | 2026-11-09 02:10:16.385 UTC [293] user=app_ventas db=comercial app=app-ventas-web client=127.0.0.1 ERROR:  permission denied for schema auditoria at character 13
 182 | 2026-11-09 02:10:16.385 UTC [293] user=app_ventas db=comercial app=app-ventas-web client=127.0.0.1 LOG:  statement: ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes
 183 | 2026-11-09 02:10:16.385 UTC [293] user=app_ventas db=comercial app=app-ventas-web client=127.0.0.1 ERROR:  must be owner of table clientes
 187 | 2026-11-09 02:10:16.673 UTC [300] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
 188 | 2026-11-09 02:10:16.674 UTC [300] user=postgres db=comercial app=psql client=[local] LOG:  statement: ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes;
 189 | 2026-11-09 02:10:16.675 UTC [300] user=postgres db=comercial app=psql client=[local] LOG:  statement: UPDATE clientes SET rfc = 'GAMA780912GHI' WHERE id = 3;
 190 | 2026-11-09 02:10:16.677 UTC [300] user=postgres db=comercial app=psql client=[local] LOG:  statement: ALTER TABLE clientes ENABLE TRIGGER trg_auditoria_clientes;
 193 | 2026-11-09 02:10:17.987 UTC [307] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
 197 | 2026-11-09 02:10:18.288 UTC [314] user=soporte_ana db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authorized: user=soporte_ana database=comercial application_name=psql
 200 | 2026-11-09 02:10:18.570 UTC [321] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
 201 | 2026-11-09 02:10:18.571 UTC [321] user=postgres db=comercial app=psql client=[local] LOG:  statement: UPDATE clientes SET segmento = 'regular';
 204 | 2026-11-09 02:10:19.881 UTC [328] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
 207 | 2026-11-09 02:10:20.178 UTC [335] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
 210 | 2026-11-09 02:10:20.610 UTC [342] user=postgres db=comercial app=[unknown] client=[local] LOG:  connection authorized: user=postgres database=comercial application_name=psql
(73 rows)

```

```sql
SELECT id_evento, momento, usuario_sesion, aplicacion, ip_cliente, operacion, id_cliente,
       valores_antes ->> 'rfc' AS rfc_antes, valores_despues ->> 'rfc' AS rfc_despues,
       valores_antes ->> 'telefono' AS tel_antes, valores_despues ->> 'telefono' AS tel_despues
FROM auditoria.cambios_clientes ORDER BY id_evento;
```
Resultado:

```text
 id_evento |            momento            | usuario_sesion |   aplicacion   | ip_cliente | operacion | id_cliente |   rfc_antes   |  rfc_despues  | tel_antes  | tel_despues 
-----------+-------------------------------+----------------+----------------+------------+-----------+------------+---------------+---------------+------------+-------------
         1 | 2026-11-09 02:10:14.953959+00 | app_ventas     | app-ventas-web | 127.0.0.1  | UPDATE    |          3 | GAMA780912XYZ | GAMA780912ZZZ | 6679990000 | 6679990000
         2 | 2026-11-09 02:10:16.075185+00 | postgres       | psql           |            | INSERT    |          6 |               | RUPE950101AAA |            | 
         3 | 2026-11-09 02:10:16.077729+00 | postgres       | psql           |            | DELETE    |          6 | RUPE950101AAA |               |            | 
         4 | 2026-11-09 02:10:18.571556+00 | postgres       | psql           |            | UPDATE    |          1 | LOAA850315ABC | LOAA850315ABC | 6671234567 | 6671234567
         5 | 2026-11-09 02:10:18.571556+00 | postgres       | psql           |            | UPDATE    |          2 | PECA900720DEF | PECA900720DEF | 6672345678 | 6672345678
         6 | 2026-11-09 02:10:18.571556+00 | postgres       | psql           |            | UPDATE    |          4 | TOLU920201JKL | TOLU920201JKL | 6674567890 | 6674567890
         7 | 2026-11-09 02:10:18.571556+00 | postgres       | psql           |            | UPDATE    |          5 | SALA880525MNO | SALA880525MNO | 6675678901 | 6675678901
         8 | 2026-11-09 02:10:18.571556+00 | postgres       | psql           |            | UPDATE    |          3 | GAMA780912GHI | GAMA780912GHI | 6679990000 | 6679990000
(8 rows)

```

### Tu cronología

Horas en UTC, tal como las registra el servidor (la hora local de Culiacán es UTC-7: 02:09 UTC del 09-nov equivale a 19:09 del 08-nov). «Línea» = columna `num` de `dba.bitacora`; «id» = `id_evento` de `auditoria.cambios_clientes`.

| # | Fecha y hora (UTC) | Usuario | Cliente | Tipo de evento | Qué ocurrió | ¿Exitoso? | Fuente |
|---|---|---|---|---|---|---|---|
| 1 | 2026-11-09 02:09:33.657 | proceso principal (PID 1) | — | Configuración | Tras la recarga se activan `log_connections`, `log_disconnections`, el nuevo `log_line_prefix` y `log_statement = ddl` | Sí | Líneas 8–11 |
| 2 | 02:09:37.542 | app_ventas (127.0.0.1) | — | Acceso | Intento de conexión con contraseña incorrecta | No (FATAL) | Línea 19 |
| 3 | 02:09:37.797 | usuario_inexistente (127.0.0.1) | — | Acceso | Intento de conexión con un rol que no existe | No (FATAL) | Línea 22 |
| 4 | 02:09:38.055 | app_ventas / app-ventas-web (127.0.0.1) | — | Acceso | Conexión exitosa con contraseña correcta | Sí | Línea 27 |
| 5 | 02:09:39.999 | postgres (psql, local) | — | Privilegio | `REVOKE UPDATE ... FROM soporte_ana` y `GRANT UPDATE ... TO app_ventas` | Sí | Líneas 37–38 |
| 6 | 02:09:40.002 | postgres (psql, local) | — | Estructura | `ALTER TABLE clientes ADD COLUMN segmento` | Sí | Línea 39 |
| 7 | 02:09:40.003 | postgres (psql, local) | — | Privilegio | `CREATE ROLE rol_temporal ... PASSWORD '...'` y `DROP ROLE`; la contraseña quedó en texto claro en la bitácora | Sí | Líneas 40–41 |
| 8 | 02:09:41.638 | app_ventas / app-ventas-web (127.0.0.1) | 3 (según la actividad) | Datos | Hay una conexión de app_ventas. El UPDATE del RFC a `XYZ` (Act. 7) sí se ejecutó (`UPDATE 1` en la salida del cliente), pero con `ddl` el servidor no registró la sentencia | Sí, pero sin registro en el servidor | Línea 48 (solo la conexión); evidencia 07 |
| 9 | 02:09:43.241 | postgres (psql, local) | — | Configuración | `ALTER SYSTEM SET log_statement = 'mod'`; el proceso principal confirma el cambio | Sí | Líneas 55 y 58 |
| 10 | 02:09:46.548 | app_ventas / app-ventas-web (127.0.0.1) | 3 (María García) | Datos | `UPDATE clientes SET telefono = '6679990000' WHERE id = 3` | Sí (sin error) | Línea 62 |
| 11 | 02:09:48.200 | soporte_ana (127.0.0.1) | 5 | Error | `DELETE FROM clientes WHERE id = 5` rechazado: permission denied | No | Líneas 70–71 |
| 12 | 02:09:48.482 | postgres (psql, local) | — | Error | `DROP ROLE soporte_ana` rechazado: el rol aún tiene objetos dependientes | No | Líneas 76–77 |
| 13 | 02:10:13.041 a 02:10:13.348 | postgres (psql, local) | — | Estructura | Se crean el esquema `auditoria`, la tabla, la función y el disparador | Sí | Líneas 105–107, 122, 145, 146 |
| 14 | 02:10:14.954 | app_ventas / app-ventas-web (127.0.0.1) | 3 (María García) | Datos | `UPDATE ... SET rfc = 'GAMA780912ZZZ'`; el valor anterior era `GAMA780912XYZ` | Sí | Línea 156; id 1 |
| 15 | 02:10:15.218 | app_ventas (127.0.0.1) | — | Error | `SELECT` sobre `auditoria.cambios_clientes` rechazado | No | Línea 161 |
| 16 | 02:10:16.075 y 02:10:16.077 | postgres (psql, local) | 6 (Pedro Ruiz) | Datos | Alta (INSERT) y baja (DELETE) del cliente de prueba | Sí | Líneas 172 y 174; id 2 y 3 |
| 17 | 02:10:16.384 | app_ventas / app-ventas-web (127.0.0.1) | — | Error | Intento de `DELETE` en la auditoría y de `DISABLE TRIGGER` | No | Líneas 179–183 |
| 18 | 02:10:16.674 a 02:10:16.677 | postgres (psql, local) | 3 (María García) | Datos / Configuración | Se desactiva el disparador, se cambia el RFC a `GAMA780912GHI` y se reactiva; **este cambio no quedó en la auditoría** | Sí | Líneas 188–190 (no hay fila en auditoría) |
| 19 | 02:10:18.571 | postgres (psql, local) | 1, 2, 3, 4, 5 | Datos | `UPDATE clientes SET segmento = 'regular'` sin WHERE: 1 línea de bitácora y 5 filas de auditoría | Sí | Línea 201; id 4–8 |

### Respuestas a Dirección

**1. ¿Quién cambió el RFC?**

- **Actividad 3 (`GAMA780912XXX`):** **No hay evidencia.** El cambio se hizo antes de activar `log_connections`, `log_statement` y la auditoría. La primera línea de la bitácora relacionada con `app_ventas` es la 19, posterior a ese cambio.
- **Actividad 7 (`GAMA780912XYZ`):** el cambio **sí ocurrió** (la salida del cliente mostró `UPDATE 1` y el SELECT posterior devolvió `GAMA780912XYZ`; además el id 1 confirma que ese era el valor antes de la Actividad 12). Pero **ningún registro del servidor dice quién lo hizo**: con `log_statement = ddl` el UPDATE no se registra y el disparador aún no existía. Lo único que existe es la sesión de `app_ventas` desde `app-ventas-web` a las 02:09:41.638 UTC (línea 48), que es un indicio y no una prueba de qué ejecutó.
- **Actividad 12 (`GAMA780912ZZZ`):** lo hizo **`app_ventas`**, desde la aplicación **`app-ventas-web`**, IP **127.0.0.1**, el 2026-11-09 a las 02:10:14.953959 UTC (líneas 155–156 e id_evento 1).
- **Actividad 14 (`GAMA780912GHI`):** lo hizo el rol **`postgres`** (psql, conexión local, sin IP), a las 02:10:16.675 UTC (línea 189). **No quedó fila en la auditoría**, porque el disparador estaba desactivado (líneas 188 y 190). Solo la bitácora lo delata.

**2. ¿Quién cambió el teléfono?**
**`app_ventas`**, desde `app-ventas-web` (127.0.0.1), a las 02:09:46.548 UTC (línea 62), nuevo valor `6679990000`. El valor anterior: **No hay evidencia**, porque el disparador aún no existía y la bitácora no guarda el valor previo.

**3. ¿Hubo intentos de acceso fallidos?**
Sí, dos, ambos desde **127.0.0.1**: el usuario `app_ventas` con contraseña incorrecta (02:09:37.542 UTC, línea 19) y el usuario `usuario_inexistente`, que no existe (02:09:37.797 UTC, línea 22). Además hubo intentos rechazados por falta de permisos, que no son fallos de acceso sino de autorización: `soporte_ana` intentó borrar un cliente (líneas 70–71), `app_ventas` intentó leer y borrar la auditoría (líneas 161 y 179–180) y desactivar el disparador (líneas 182–183).

**4. ¿Qué valor tenía el RFC antes de cada cambio?**

| Cambio | Valor anterior | Fuente |
|---|---|---|
| Actividad 3 (XXX) | **No hay evidencia** de este cambio ni de su valor previo | — |
| Actividad 7 (XYZ) | **No hay registro del servidor.** Por la salida del cliente y el id 1 se sabe que el valor resultante fue `XYZ`, pero no el anterior | — |
| Actividad 12 (ZZZ) | `GAMA780912XYZ` | id_evento 1 (`valores_antes`) |
| Actividad 14 (GHI) | **No hay registro directo.** Se infiere `GAMA780912ZZZ` porque fue el último valor auditado, pero ningún registro lo prueba | Hueco: disparador desactivado |

**Conclusión:** la configuración permite demostrar quién cambió un dato sensible y qué valor tenía antes **solo cuando el cambio ocurrió después de activar la bitácora y la auditoría y sin que se desactivara el disparador** (Actividad 12). No lo permite para cambios anteriores a esa configuración (Actividades 3 y 7, que ocurrieron pero sin registro suficiente en el servidor), para el cambio hecho con el disparador desactivado (Actividad 14, que solo se detecta comparando bitácora con auditoría), ni para lecturas (las consultas de `soporte_ana` no dejan rastro).
