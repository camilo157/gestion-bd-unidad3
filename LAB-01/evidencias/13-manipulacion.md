# Actividad 14 — Intentar manipular la auditoría

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 14
- **Fecha de ejecución:** 2026-11-08 19:10:16 HMM

```bash
psql "postgresql://app_ventas:<REDACTED>@127.0.0.1/comercial?application_name=app-ventas-web" -c "DELETE FROM auditoria.cambios_clientes" -c "ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes"
```
Resultado:

```text
ERROR:  permission denied for schema auditoria
LINE 1: DELETE FROM auditoria.cambios_clientes
                    ^
ERROR:  must be owner of table clientes
```


### Desde el administrador

```sql
ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes;
UPDATE clientes SET rfc = 'GAMA780912GHI' WHERE id = 3;
ALTER TABLE clientes ENABLE TRIGGER trg_auditoria_clientes;
SELECT count(*) FROM auditoria.cambios_clientes;
```
Resultado:

```text
ALTER TABLE
UPDATE 1
ALTER TABLE
 count 
-------
     3
(1 row)

```

```sql
SELECT linea FROM dba.bitacora
WHERE linea ~ 'statement: (ALTER TABLE clientes (DIS|EN)ABLE|UPDATE clientes SET rfc = .GAMA780912GHI)'
ORDER BY num;
```
Resultado:

```text
                                                                                      linea                                                                                      
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 2026-11-09 02:10:16.385 UTC [293] user=app_ventas db=comercial app=app-ventas-web client=127.0.0.1 LOG:  statement: ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes
 2026-11-09 02:10:16.674 UTC [300] user=postgres db=comercial app=psql client=[local] LOG:  statement: ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes;
 2026-11-09 02:10:16.675 UTC [300] user=postgres db=comercial app=psql client=[local] LOG:  statement: UPDATE clientes SET rfc = 'GAMA780912GHI' WHERE id = 3;
 2026-11-09 02:10:16.677 UTC [300] user=postgres db=comercial app=psql client=[local] LOG:  statement: ALTER TABLE clientes ENABLE TRIGGER trg_auditoria_clientes;
(4 rows)

```


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **Evidencia de un cambio sin auditar:** en la bitácora aparecen DISABLE TRIGGER, el UPDATE y ENABLE TRIGGER, pero no existe la fila correspondiente en `auditoria.cambios_clientes` (el conteo no aumentó).
2. **Control administrativo:** separar a quien opera la base de quien custodia la evidencia, doble autorización para cambios sobre el disparador, revisión periódica, y envío de bitácoras a un sistema externo administrado por otra área.
3. **Separación de funciones (Unidad II):** ningún rol debe concentrar operar y auditar; un administrador con control total puede desactivar los controles internos, por eso la custodia debe ser externa.

