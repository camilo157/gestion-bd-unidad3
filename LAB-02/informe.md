# Informe LAB-02 — Trazabilidad en MongoDB Community

**Estudiante:** < Jose Camilo Angulo Rivera >  **Fecha:** <16/11/2026>

## 1. Despliegue, edición y limitación
Servidor MongoDB 7 Community en contenedor Docker (`mongo:7`, `--auth`). **Hecho verificado:** `buildInfo.modules` está vacío y la auditoría nativa (`--auditDestination`) no existe en esta edición; solo está en Enterprise y Atlas M10+ (REF-U3-04). Esto significa que no puede registrarse de forma nativa quién cambió privilegios ni CRUD con atribución garantizada. Por eso se trabajó con el perfilador, la bitácora de `mongod` y un control compensatorio, sin presentar ninguno como auditoría.

## 2. Perfilador
- **Configuración:** nivel 2 (todo) en la base `comercial` y luego nivel 1 con filtro `op ∈ {insert, update, remove}`. Se aplicó con `db.setProfilingLevel()`, que **no persiste** tras reiniciar.
- **Interpretación:** cada documento de `system.profile` indica `op`, `ns`, `user` (`app_ventas@comercial`), `client`, `appName` y `ts`. Permite saber quién modificó qué, desde dónde y cuándo.
- **Costo y límites:** nivel 2 degrada rendimiento y registra filtros con posibles datos personales; la colección es de 1 MB y se sobrescribe; **no guarda el valor anterior** ni el contenido del documento eliminado.

## 3. Bitácora de mongod
- **Dónde se escribe:** salida estándar del contenedor (`docker logs`); no hay `systemLog.destination: file`. `getLog` devuelve solo los 1024 eventos recientes y se vacía al reiniciar.
- **Accesos:** `Failed to authenticate` (con `result` y `error`, distingue contraseña incorrecta de usuario inexistente) y `Successfully authenticated`. El nombre de aplicación de los intentos fallidos lo declara el cliente (`mongosh x.y.z`).
- **Cambios de configuración:** `Profiler settings changed` no incluye usuario, pero se atribuye correlacionando `ctx` con `Successfully authenticated` (válido solo sin reinicios entre ambos eventos).

## 4. Privilegios
- **Evidencia disponible:** ninguna en el perfilador ni en la bitácora para `grantRolesToUser` (0 resultados).
- **Control compensatorio:** instantáneas periódicas de usuarios y roles en `auditoria.instantaneas_privilegios`. Detectan **qué** cambió y entre qué dos momentos, pero **no quién ni cuándo exacto**. No equivalen a auditoría.

## 5. Conservación
Riesgos observados: sobrescritura de `system.profile` (1 MB), vaciado de `getLog` al reiniciar, perfilador que vuelve a nivel 0 tras el reinicio, y dependencia de la salida estándar del contenedor. Se exportaron `system-profile.json`, `bitacora-mongod.log` (y la salida completa del contenedor) con hash SHA-256 en `hashes.sha256`. Para persistencia real se configuraría `systemLog` y `operationProfiling.mode` en el archivo de configuración (REF-U3-21); **no se aplicó** en este laboratorio.

## 6. Comparación
Ver `evidencias/09-comparacion.md` (PostgreSQL vs. MongoDB Community vs. Enterprise/Atlas). Las columnas de Enterprise/Atlas son «documentado, no practicado».

## 7. Recomendación
Para una organización que necesite auditar cambios de privilegios en MongoDB:
- **Hecho verificado:** en Community no es posible registrar quién cambió un privilegio; solo detectar el cambio con instantáneas.
- **Recomendación:** evaluar MongoDB Enterprise o Atlas (M10+) para obtener auditoría nativa de autorización y CRUD, y enviar esos registros a un sistema externo bajo otra custodia. Si no se puede, mantener el control compensatorio, restringir quién administra usuarios (separación de funciones) y registrar fuera del servidor cada solicitud de cambio de privilegios.
- **Supuestos (no verificados aquí):** volumen y costo de la auditoría nativa, requisitos regulatorios aplicables y capacidad de la organización para custodiar los registros externamente.

## Preguntas de reflexión
1. **¿Por qué el perfilador no es auditoría de seguridad?** Fue diseñado para analizar desempeño, puede apagarse o modificarse, se sobrescribe y no registra eventos de seguridad como los cambios de privilegios.
2. **¿Por qué sí aporta trazabilidad?** Registra quién (`user`), desde dónde (`client`), con qué aplicación (`appName`) y cuándo (`ts`) se ejecutó cada operación.
3. **Riesgo del nivel 2:** los filtros de las consultas pueden contener datos personales, y `system.profile` pasa a ser otro depósito de datos sensibles, además del costo de rendimiento.
4. **Detectar vs. atribuir:** detectar es saber que algo cambió (instantáneas); atribuir es saber quién lo hizo, lo cual exige que la identidad quede en el registro.
5. **¿Por qué reconocer una limitación es parte del trabajo del DBA?** Evita una falsa sensación de seguridad, permite decidir con información (riesgo aceptado, control compensatorio o cambio de edición) y evita presentar evidencia que no existe.
