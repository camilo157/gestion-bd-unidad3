# Actividad 6 — Cambios de privilegios y estructura

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 6
- **Fecha de ejecución:** 2026-11-08 19:09:39 HMM

Script `sql/03-privilegios-estructura.sql` (psql -a: cada sentencia seguida de su resultado):

```text
-- Actividad 6 — Cambios de privilegios y de estructura (con log_statement = 'ddl')
REVOKE UPDATE ON clientes FROM soporte_ana;
REVOKE
GRANT UPDATE ON clientes TO app_ventas;
GRANT
ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20);
ALTER TABLE
-- 12.1 La bitácora puede filtrar secretos (contraseña de PRÁCTICA, rol desechable)
CREATE ROLE rol_temporal LOGIN PASSWORD 'Temporal_Practica_2026';
CREATE ROLE
DROP ROLE rol_temporal;
DROP ROLE
-- Consulta de verificación (en una consulta posterior):
-- SELECT linea FROM dba.bitacora WHERE linea LIKE '%statement:%' ORDER BY num;
```

```sql
SELECT linea FROM dba.bitacora WHERE linea LIKE '%statement:%' ORDER BY num;
```
Resultado:

```text
                                                                                  linea                                                                                  
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 2026-11-09 02:09:39.999 UTC [124] user=postgres db=comercial app=psql client=[local] LOG:  statement: REVOKE UPDATE ON clientes FROM soporte_ana;
 2026-11-09 02:09:40.001 UTC [124] user=postgres db=comercial app=psql client=[local] LOG:  statement: GRANT UPDATE ON clientes TO app_ventas;
 2026-11-09 02:09:40.002 UTC [124] user=postgres db=comercial app=psql client=[local] LOG:  statement: ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20);
 2026-11-09 02:09:40.003 UTC [124] user=postgres db=comercial app=psql client=[local] LOG:  statement: CREATE ROLE rol_temporal LOGIN PASSWORD 'Temporal_Practica_2026';
 2026-11-09 02:09:40.010 UTC [124] user=postgres db=comercial app=psql client=[local] LOG:  statement: DROP ROLE rol_temporal;
(5 rows)

```


Para la exportación final se sustituye la contraseña `Temporal_Practica_2026` por `<REDACTED>`. **Revisa que este .md no exponga secretos reales antes de subirlo** (aquí es una contraseña de práctica).


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **Tipo de evento:** REVOKE y GRANT = *privilegio*; ALTER TABLE = *estructura* (CREATE ROLE/DROP ROLE también son privilegio).
2. **¿Por qué GRANT/REVOKE se registran con `ddl`?** Porque `log_statement = ddl` incluye CREATE/ALTER/DROP y también GRANT, REVOKE y COMMENT.
3. **¿Quién debería leer la bitácora si contiene contraseñas?** Solo el DBA/custodio autorizado. Se relaciona con la gestión de secretos de la Unidad II: no escribir contraseñas en SQL (usar `\password`, que envía un hash SCRAM), y rotar cualquier secreto que haya quedado en una bitácora.

