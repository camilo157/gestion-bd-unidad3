# Actividad 9 — Comparar los tres escenarios

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 9
- **Fecha de ejecución:** 2026-11-15 22:36:11 HMM
- **Nota:** en cada bloque de código, `bitacora()` es la función auxiliar de la sección 6.4 (definida al inicio de cada sesión).

Valores: **Sí** (observado), **Parcial** (se explica), **No**. Para Enterprise/Atlas: «Documentado, no practicado».

| Evento auditable | PostgreSQL (bitácora + disparador) | MongoDB Community (perfilador + bitácora) | MongoDB Enterprise/Atlas (auditoría nativa) |
|---|---|---|---|
| Acceso exitoso | Sí (`log_connections`: `connection authorized`) | Sí (`Successfully authenticated` en la bitácora) | Documentado, no practicado |
| Acceso fallido | Sí (`FATAL: password authentication failed`) | Sí (`Failed to authenticate`, con `result` y error) | Documentado, no practicado |
| Cambio de privilegios | Sí (`GRANT`/`REVOKE` con `log_statement = ddl`) | No en perfilador ni bitácora; solo **Parcial** con instantáneas (detecta qué cambió, no quién ni cuándo exacto) | Documentado, no practicado (autorización) |
| Cambio de estructura | Sí (`ALTER TABLE`, `CREATE`... con `ddl`) | Parcial (no probado en este laboratorio; el perfilador no está diseñado para auditar DDL) | Documentado, no practicado (cambios de esquema/DDL) |
| Modificación de datos | Sí (`log_statement = mod` y disparador) | Sí (perfilador: `update`/`remove` con usuario, cliente, aplicación y momento) | Documentado, no practicado (CRUD con `auditAuthorizationSuccess: true`) |
| Valor anterior del dato | Sí (disparador: `valores_antes`) | No (el perfilador guarda el comando, no el documento anterior) | Documentado, no practicado (no se afirma sin verificarlo) |
| Lectura de datos sensibles | Parcial (con `mod` las lecturas no aparecen, observado; `all` y pgaudit no practicados) | Parcial/Sí con nivel 2 (observado en la Actividad 3), con costo de desempeño y exposición de datos | Documentado, no practicado (CRUD) |
| Cambio de configuración del registro | Sí (`parameter ... changed to ...`) | Parcial (`Profiler settings changed`; el usuario se obtiene correlacionando `ctx`) | Documentado, no practicado |

**Limitación central:** en MongoDB Community no existe auditoría nativa; el perfilador es una herramienta de desempeño y las instantáneas son un control compensatorio.
