# Actividad 15 — Límites: lecturas y volumen

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 15
- **Fecha de ejecución:** 2026-11-08 19:10:18 HMM

```bash
psql "postgresql://soporte_ana:<REDACTED>@127.0.0.1/comercial" -c "SELECT nombre, rfc, telefono FROM clientes WHERE id = 3"
```
Resultado:

```text
    nombre    |      rfc      |  telefono  
--------------+---------------+------------
 María García | GAMA780912GHI | 6679990000
(1 row)

```

```sql
UPDATE clientes SET segmento = 'regular';
```
Resultado:

```text
UPDATE 5
```

```sql
SELECT count(*) AS lineas_bitacora FROM dba.bitacora
WHERE linea LIKE '%statement: UPDATE clientes SET segmento%';
SELECT operacion, count(*) FROM auditoria.cambios_clientes GROUP BY operacion ORDER BY operacion;
SELECT count(*) AS lecturas_soporte FROM dba.bitacora
WHERE linea LIKE '%user=soporte_ana%SELECT nombre, rfc%';
```
Resultado:

```text
 lineas_bitacora 
-----------------
               1
(1 row)

 operacion | count 
-----------+-------
 DELETE    |     1
 INSERT    |     1
 UPDATE    |     6
(3 rows)

 lecturas_soporte 
------------------
                0
(1 row)

```


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **UPDATE sin WHERE sobre 1 000 000 de filas:** una sola línea en la bitácora, pero un millón de filas en la auditoría (crecimiento de tabla, E/S, WAL y tiempo del UPDATE).
2. **¿Quién autoriza depurar `auditoria.cambios_clientes`?** Un responsable de seguridad/cumplimiento junto con el área legal y el DBA, con aprobación documentada; nunca la aplicación ni el DBA por sí solo.
3. **¿Por qué `log_statement = 'all'` crea un nuevo depósito de datos sensibles?** Porque registra consultas completas con valores literales (RFC, teléfonos, secretos) sin los controles de la tabla original.

