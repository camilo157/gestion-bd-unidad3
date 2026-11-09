# Actividad 12 — El incidente auditado

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 12
- **Fecha de ejecución:** 2026-11-08 19:10:14 HMM

```bash
psql "postgresql://app_ventas:<REDACTED>@127.0.0.1/comercial?application_name=app-ventas-web" -c "UPDATE clientes SET rfc = 'GAMA780912ZZZ' WHERE id = 3"
```
Resultado:

```text
UPDATE 1
```

```bash
psql "postgresql://app_ventas:<REDACTED>@127.0.0.1/comercial" -c "SELECT * FROM auditoria.cambios_clientes"
```
Resultado:

```text
ERROR:  permission denied for schema auditoria
LINE 1: SELECT * FROM auditoria.cambios_clientes
                      ^
```

```sql
\x
SELECT id_evento, momento, usuario_sesion, usuario_efectivo, aplicacion, ip_cliente, operacion, id_cliente
FROM auditoria.cambios_clientes ORDER BY id_evento;
\x
```
Resultado:

```text
Expanded display is on.
-[ RECORD 1 ]----+------------------------------
id_evento        | 1
momento          | 2026-11-09 02:10:14.953959+00
usuario_sesion   | app_ventas
usuario_efectivo | postgres
aplicacion       | app-ventas-web
ip_cliente       | 127.0.0.1
operacion        | UPDATE
id_cliente       | 3

Expanded display is off.
```

Script `sql/06-campos-modificados.sql` (psql -a: cada sentencia seguida de su resultado):

```text
-- Actividad 12 — ¿Qué campo cambió? (compara valores_antes con valores_despues)
SELECT a.id_evento, a.momento, a.usuario_sesion, a.ip_cliente,
       d.key                     AS campo,
       a.valores_antes ->> d.key AS antes,
       d.value #>> '{}'          AS despues
FROM auditoria.cambios_clientes a
CROSS JOIN LATERAL jsonb_each(a.valores_despues) d
WHERE a.operacion = 'UPDATE'
  AND a.valores_antes -> d.key IS DISTINCT FROM d.value
ORDER BY a.id_evento;
 id_evento |            momento            | usuario_sesion | ip_cliente | campo |     antes     |    despues    
-----------+-------------------------------+----------------+------------+-------+---------------+---------------
         1 | 2026-11-09 02:10:14.953959+00 | app_ventas     | 127.0.0.1  | rfc   | GAMA780912XYZ | GAMA780912ZZZ
(1 row)

```


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **Hipótesis vs. resultado:** sin SECURITY DEFINER el UPDATE habría fallado; con él funciona. `usuario_efectivo = postgres` (propietario de la función) y `usuario_sesion = app_ventas` (quién provocó el cambio).
2. **Restaurar el valor anterior:** `UPDATE clientes SET rfc = 'GAMA780912XYZ' WHERE id = 3;`
3. **¿`aplicacion` o `ip_cliente`?** `ip_cliente` aporta más valor porque la ve el servidor; `aplicacion` la declara el propio cliente y es fácil de falsificar. (La IP puede ser de un NAT o proxy.)

