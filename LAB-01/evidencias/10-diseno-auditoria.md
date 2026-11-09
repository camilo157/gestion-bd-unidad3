# Actividad 10 — Diseñar y crear el registro de auditoría

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 10
- **Fecha de ejecución:** 2026-11-08 19:10:12 HMM


| Campo | Tipo | ¿Qué pregunta responde? | ¿Nulo? ¿Por qué? |
|---|---|---|---|
| id_evento | BIGSERIAL | Identifica y ordena cada evento (referencia en el informe) | No: clave primaria |
| momento | TIMESTAMPTZ | ¿Cuándo? | No: todo evento tiene hora |
| usuario_sesion | TEXT | ¿Quién? (rol autenticado) | No: siempre existe |
| usuario_efectivo | TEXT | Con qué privilegios corrió (propietario en SECURITY DEFINER) | No |
| aplicacion | TEXT | ¿Desde qué aplicación? | Sí: lo declara el cliente y puede estar vacío |
| ip_cliente | INET | ¿Desde qué equipo? | Sí: NULL en conexiones por socket local |
| operacion | TEXT | ¿Qué tipo de cambio? | No |
| id_cliente | BIGINT | ¿Qué registro? | Sí: por si se auditan eventos sin fila concreta |
| valores_antes | JSONB | ¿Qué valor tenía antes? | Sí: NULL en INSERT |
| valores_despues | JSONB | ¿Qué valor quedó? | Sí: NULL en DELETE |

Script `sql/04-esquema-auditoria.sql` (psql -a: cada sentencia seguida de su resultado):

```text
-- Actividad 10 — Esquema y tabla de auditoría
CREATE SCHEMA auditoria;
CREATE SCHEMA
REVOKE ALL ON SCHEMA auditoria FROM PUBLIC;
REVOKE
CREATE TABLE auditoria.cambios_clientes (
    id_evento        BIGSERIAL PRIMARY KEY,
    momento          TIMESTAMPTZ NOT NULL DEFAULT now(),
    usuario_sesion   TEXT        NOT NULL DEFAULT session_user,
    usuario_efectivo TEXT        NOT NULL DEFAULT current_user,
    aplicacion       TEXT        DEFAULT current_setting('application_name'),
    ip_cliente       INET        DEFAULT inet_client_addr(),
    operacion        TEXT        NOT NULL,
    id_cliente       BIGINT,
    valores_antes    JSONB,
    valores_despues  JSONB
);
CREATE TABLE
```


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **¿Por qué `TIMESTAMPTZ`?** Guarda un instante absoluto, sin ambigüedad de zona horaria ni de horario de verano, lo que permite correlacionar con otras fuentes.
2. **¿Por qué el registro completo en JSONB?** Conserva el estado completo aunque `clientes` cambie de estructura, y permite comparar cualquier campo o restaurar el registro.
3. **La tabla contiene RFC:** es dato personal; debe clasificarse al menos como `clientes`, con acceso solo para DBA/auditor, y entrar en la política de retención y minimización.

