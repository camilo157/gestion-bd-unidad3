# Actividad 3 — El incidente sin bitácora

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 3
- **Fecha de ejecución:** 2026-11-08 19:09:31 HMM

```bash
psql "postgresql://app_ventas:<REDACTED>@127.0.0.1/comercial?application_name=app-ventas-web" -c "UPDATE clientes SET rfc = 'GAMA780912XXX' WHERE id = 3"
```
Resultado:

```text
UPDATE 1
```

```sql
SELECT linea FROM dba.bitacora
WHERE linea ILIKE '%update%' OR linea LIKE '%app_ventas%';
```
Resultado:

```text
 linea 
-------
(0 rows)

```


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **¿Se puede demostrar quién modificó el RFC?** No: no hay ninguna línea del cambio ni de la conexión.
2. **¿Se puede demostrar que no fue `soporte_ana`?** Tampoco. Solo se sabe que, por privilegios, ella solo tenía SELECT; pero sin bitácora no hay evidencia de lo ocurrido.
3. **¿Los privilegios impidieron el cambio?** No, y no debían: `app_ventas` tiene UPDATE por su función. El control de acceso dice quién *puede*, no deja evidencia de quién *lo hizo*.
4. **Qué debía estar configurado antes:** logging_collector, log_connections/log_disconnections, un `log_line_prefix` con `%u %d %a %h`, `log_statement` en `mod` (o más) y la auditoría a nivel de dato.

