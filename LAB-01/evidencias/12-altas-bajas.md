# Actividad 13 — Altas y bajas

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 13
- **Fecha de ejecución:** 2026-11-08 19:10:15 HMM

```sql
INSERT INTO clientes (nombre, correo, rfc, edad, ciudad, codigo_postal)
VALUES ('Pedro Ruiz', 'pedro.ruiz@example.test', 'RUPE950101AAA', 30, 'Guasave', '81000');
DELETE FROM clientes WHERE nombre = 'Pedro Ruiz';

SELECT id_evento, usuario_sesion, aplicacion, ip_cliente, operacion, id_cliente,
       valores_antes ->> 'rfc' AS rfc_antes, valores_despues ->> 'rfc' AS rfc_despues
FROM auditoria.cambios_clientes ORDER BY id_evento;
```
Resultado:

```text
INSERT 0 1
DELETE 1
 id_evento | usuario_sesion |   aplicacion   | ip_cliente | operacion | id_cliente |   rfc_antes   |  rfc_despues  
-----------+----------------+----------------+------------+-----------+------------+---------------+---------------
         1 | app_ventas     | app-ventas-web | 127.0.0.1  | UPDATE    |          3 | GAMA780912XYZ | GAMA780912ZZZ
         2 | postgres       | psql           |            | INSERT    |          6 |               | RUPE950101AAA
         3 | postgres       | psql           |            | DELETE    |          6 | RUPE950101AAA | 
(3 rows)

```


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **Evidencia de que Pedro Ruiz existió:** `auditoria.cambios_clientes` (el DELETE conserva todo el registro en `valores_antes`).
2. **`ip_cliente` vacía:** la sesión del administrador es local por socket Unix, sin IP.
3. **Conflicto con la retención:** la política pide eliminar datos innecesarios, pero la auditoría conserva una copia con datos personales (RFC). Debe resolverlo el responsable de datos/cumplimiento con el área legal, definiendo una retención propia para la auditoría y minimizando lo que se guarda.

