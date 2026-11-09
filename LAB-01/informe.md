# Informe — Bitácoras y auditoría del dato (Unidad III)

**Estudiante:** < Jose Camilo Angulo Rivera >  **Fecha:** < 08/11/2026 >

> Borrador. Completa con tus datos reales (versiones, líneas, id_evento) y reescribe con tus palabras.

## 1. Despliegue y situación inicial
Servidor PostgreSQL 16 en contenedor Docker `dba-u3-pg` (imagen oficial). Con la configuración por defecto (`logging_collector=off`, `log_connections=off`, `log_statement=none`, prefijo `%m [%p]`) la bitácora no registraba conexiones, sentencias ni usuario/IP, y el destino lo decidía el contenedor, no PostgreSQL. Por eso no se podía responder a Dirección quién, cuándo, desde dónde ni qué valor tenía el RFC (Actividad 3: 0 filas). Además, las reglas `host` con `trust` impedían ver accesos fallidos hasta cambiarlas a `scram-sha-256`.

## 2. Configuración aplicada
| Parámetro | Valor | Cambio requerido | Justificación |
|---|---|---|---|
| logging_collector | on | Reinicio | El servidor administra y permite leer su propia bitácora de forma portable |
| log_connections / log_disconnections | on | Recarga | Accesos exitosos/fallidos y duración de sesión |
| log_line_prefix | `%m [%p] user=%u db=%d app=%a client=%h ` | Recarga | Sin quién/dónde/qué app la línea no sirve de evidencia |
| log_statement | ddl → mod | Recarga | `ddl` registra privilegios y estructura; `mod` agrega INSERT/UPDATE/DELETE. `all` se descarta por volumen y exposición de datos |

## 3. Eventos observados (un ejemplo interpretado de cada tipo)
Completa con la línea y su interpretación: **acceso** (Act. 5), **privilegio** (Act. 6), **estructura** (Act. 6), **datos** (Act. 7), **error** (Act. 8), **configuración** (`parameter ... changed to ...`, Act. 4). Para cada uno indica qué prueba y qué no prueba.

## 4. Auditoría del dato
- Tabla `auditoria.cambios_clientes` en esquema sin acceso público; guarda el registro completo en JSONB (antes/después), momento, usuario de sesión, usuario efectivo, aplicación e IP.
- **SECURITY DEFINER** permite que `app_ventas` provoque la escritura sin tener privilegios sobre `auditoria`; con **`search_path` fijo** se evita que alguien inyecte objetos homónimos que se ejecuten con privilegios del propietario.
- **`session_user`** identifica a quien provocó el cambio; `current_user` dentro de la función devuelve al propietario (`postgres`).
- Resultado del incidente auditado: pega aquí el cambio `rfc: GAMA780912XYZ → GAMA780912ZZZ`, usuario `app_ventas`, app `app-ventas-web`, IP, id_evento.

## 5. Limitaciones
- **Lecturas:** ni `mod` ni el disparador registran SELECT; `all` sí, pero con volumen y riesgo; `pgaudit` (Parte C) permite auditoría por columna.
- **Volumen:** un UPDATE sin WHERE = 1 línea de bitácora y N filas de auditoría.
- **Administrador con control total:** puede desactivar el disparador o cambiar `log_statement`; el rastro queda en la bitácora, pero quien controla el servidor puede alterarla. Mitigación: envío a sistema externo y separación entre quien opera y quien custodia.

## 6. Riesgos de la bitácora
Secretos expuestos (`CREATE ROLE ... PASSWORD` quedó en texto claro), datos personales en sentencias, pérdida por rotación/reinstalación, y acceso de terceros a un archivo que lo revela todo. Controles: acceso restringido, redacción antes de exportar, hash SHA-256 guardado fuera del servidor, copia externa y política de retención.

## 7. Cronología y conclusión
Incluye o referencia `evidencias/15-cronologia.md`. Conclusión sugerida: con esta configuración **sí** puede demostrarse quién cambió un dato sensible y qué valor tenía antes **para los cambios posteriores a la activación** (Act. 12), pero **no** para el cambio de la Actividad 3 (ocurrido antes de configurar), ni para lecturas, ni frente a un administrador que desactive el disparador sin control externo. Si varias personas comparten `app_ventas`, la bitácora identifica el rol, no a la persona.

## Preguntas de reflexión (borrador)
1. **Auditoría después del incidente:** lo que no se registró no puede reconstruirse; no hay evidencia retroactiva.
2. **Colector propio del servidor:** la evidencia queda bajo control de PostgreSQL, es portable entre despliegues y se puede leer con SQL, en vez de depender del mecanismo de despliegue.
3. **Prefijo de línea:** sin `%u %d %a %h` se sabe *qué* ocurrió pero no *quién* ni *desde dónde*.
4. **Sentencia vs. cambio en el dato:** la sentencia dice qué se ejecutó; la auditoría de dato conserva el valor anterior y nuevo de cada fila afectada.
5. **`pg_stat_activity` vs. bitácora:** la vista es el estado actual (sesiones vivas); la bitácora es la historia. Cada una cubre lo que la otra no.
6. **¿Quién audita al administrador?** Una función separada (seguridad/auditoría) con bitácoras enviadas a un sistema externo que el DBA no controle, doble autorización y revisión periódica.
