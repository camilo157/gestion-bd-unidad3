#!/usr/bin/env bash
# Ejecuta las Partes A y B del laboratorio de Unidad III en un contenedor Docker
# y genera evidencias/*.md, bitacora-lab01.log y bitacora-lab01.sha256
#
# Uso:  ESTUDIANTE="Tu Nombre" ./ejecutar-lab.sh
# Opciones (variables de entorno):
#   RECREAR=1   borra y recrea el contenedor si ya existe
#   C=nombre    nombre del contenedor (por defecto dba-u3-pg)
#   PUERTO=5432 puerto publicado en tu equipo
set -u
cd "$(dirname "$0")"
ESTUDIANTE="${ESTUDIANTE:-<TU NOMBRE>}"
C="${C:-dba-u3-pg}"
PUERTO="${PUERTO:-5432}"
P_VENTAS="Ventas_Practica_2026"
P_SOPORTE="Soporte_Practica_2026"
SLEEP_S=20          # la guía usa 90 s para pg_sleep; 20 s basta para la evidencia
mkdir -p evidencias

# ---------- utilidades ----------
ev_start(){ EV="evidencias/$1"; { echo "# $2"; echo; echo "- **Estudiante:** $ESTUDIANTE"; echo "- **Actividad:** $3"; echo "- **Fecha de ejecución:** $(date '+%Y-%m-%d %H:%M:%S %Z')"; echo; } > "$EV"; echo ">> $EV"; }
say(){ printf '\n%b\n\n' "$*" >> "$EV"; }
resp(){ { echo; echo "## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)"; echo; cat; echo; } >> "$EV"; }
sqladm(){ local q; q="$(cat)"; { echo '```sql'; echo "$q"; echo '```'; echo 'Resultado:'; echo; echo '```text'; printf '%s\n' "$q" | docker exec -i "$C" psql -U postgres -d comercial -X 2>&1; echo '```'; echo; } >> "$EV"; }
sqlfile(){ { echo "Script \`$1\` (psql -a: cada sentencia seguida de su resultado):"; echo; echo '```text'; docker exec -i "$C" psql -U postgres -d comercial -X -a < "$1" 2>&1; echo '```'; echo; } >> "$EV"; }
netsql(){
  local u="$1" p="$2" a="$3"; shift 3
  local uri="postgresql://$u:$p@127.0.0.1/comercial" shown="postgresql://$u:<REDACTED>@127.0.0.1/comercial"
  if [ -n "$a" ]; then uri="$uri?application_name=$a"; shown="$shown?application_name=$a"; fi
  local args=() disp=""
  for s in "$@"; do args+=(-c "$s"); disp+=" -c \"$s\""; done
  { echo '```bash'; echo "psql \"$shown\"$disp"; echo '```'; echo 'Resultado:'; echo; echo '```text'; docker exec -i "$C" psql "$uri" -X "${args[@]}" 2>&1; echo '```'; echo; } >> "$EV"
}
esperar(){
  for i in $(seq 1 90); do docker logs "$C" 2>&1 | grep -q "init process complete" && break; sleep 1; done
  sleep 2
  for i in $(seq 1 60); do docker exec "$C" pg_isready -U postgres >/dev/null 2>&1 && break; sleep 1; done
  sleep 3
}
reload_wait(){ sleep 3; }

# ---------- 0. Despliegue ----------
if docker ps -a --format '{{.Names}}' | grep -qx "$C"; then
  if [ "${RECREAR:-0}" = "1" ]; then docker rm -f "$C" >/dev/null; else echo "El contenedor $C ya existe. Usa RECREAR=1 para borrarlo y empezar limpio."; exit 1; fi
fi
docker run --name "$C" -e POSTGRES_PASSWORD=Practica_U3_2026 -e POSTGRES_DB=comercial -p "$PUERTO:5432" -d postgres:16 >/dev/null || exit 1
esperar

# ---------- 6.3 / 6.4 Entorno y pg_hba ----------
ev_start 00-entorno.md "Entorno y reglas de autenticación (secciones 6.3 y 6.4)" "Preparación"
say "Despliegue: contenedor Docker \`$C\` con la imagen oficial \`postgres:16\`."
sqladm <<'SQL'
SELECT version();
SHOW data_directory;
SHOW config_file;
SHOW hba_file;
SELECT line_number, type, database, user_name, address, auth_method FROM pg_hba_file_rules WHERE database = '{all}';
SQL
say "Cambio de trust a scram-sha-256 en las reglas host de 127.0.0.1 y ::1 (Anexo A.2):"
{ echo '```bash'; echo "docker exec $C bash -c \"sed -i -E 's/^(host +all +all +(127\\.0\\.0\\.1\\/32|::1\\/128) +)trust/\\1scram-sha-256/' /var/lib/postgresql/data/pg_hba.conf\""; echo '```'; } >> "$EV"
docker exec "$C" bash -c "sed -i -E 's/^(host +all +all +(127\.0\.0\.1\/32|::1\/128) +)trust/\1scram-sha-256/' /var/lib/postgresql/data/pg_hba.conf"
sqladm <<'SQL'
SELECT pg_reload_conf();
SQL
reload_wait
sqladm <<'SQL'
SELECT line_number, type, database, user_name, address, auth_method FROM pg_hba_file_rules WHERE database = '{all}';
SQL
resp <<'R'
**¿Por qué una regla `trust` afecta lo que la bitácora puede demostrar sobre la identidad?**
Con `trust` el servidor acepta el nombre de usuario que declara el cliente sin verificar nada. La bitácora registraría un `user=` que cualquiera pudo escribir, y nunca habría accesos fallidos. Es el mismo principio de endurecimiento de la Unidad II: sin autenticación fuerte (scram-sha-256) el usuario registrado no prueba la identidad real.
R

# ---------- 6.5 Datos y roles ----------
ev_start 00b-preparacion.md "Preparación de datos y roles (sección 6.5)" "Preparación"
sqlfile sql/00-preparacion.sql
docker exec -i "$C" psql -U postgres -d comercial -X -c "ALTER ROLE app_ventas PASSWORD '$P_VENTAS'" -c "ALTER ROLE soporte_ana PASSWORD '$P_SOPORTE'" >/dev/null 2>&1
say "Contraseñas de práctica asignadas con ALTER ROLE ANTES de activar log_statement (por eso no quedan en la bitácora). La guía usa \`\\password\` de forma interactiva; el resultado es equivalente. Contraseñas omitidas: \`<REDACTED>\`."

# ---------- Actividad 1 ----------
ev_start 01-configuracion-inicial.md "Actividad 1 — Configuración de registro por defecto" "1"
sqladm <<'SQL'
SELECT name, setting, source
FROM pg_settings
WHERE name IN ('log_destination','logging_collector','log_directory','log_filename',
               'log_connections','log_disconnections','log_line_prefix',
               'log_statement','log_min_error_statement','log_timezone')
ORDER BY name;
SQL
resp <<'R'
1. **¿Se registra quién se conecta?** No: `log_connections = off`.
2. **¿Se registran los UPDATE?** No: `log_statement = none`.
3. **¿La línea incluye usuario o IP?** No: el prefijo por defecto es solo `%m [%p]` (hora y PID).
4. **Zona horaria:** la de `log_timezone` (en la guía, UTC). Importa porque para correlacionar bitácora, auditoría y otros sistemas todas las marcas de tiempo deben compartir referencia horaria.
5. **Con `logging_collector = off`** decide el mecanismo de despliegue (script de arranque, systemd, Docker), no PostgreSQL.
R

# ---------- Actividad 2 ----------
ev_start 02-colector.md "Actividad 2 — Colector de bitácora y vista dba.bitacora" "2"
sqladm <<'SQL'
ALTER SYSTEM SET logging_collector = on;
SELECT name, setting, pending_restart FROM pg_settings WHERE name = 'logging_collector';
SQL
say "Reinicio del servicio: \`docker restart $C\`"
docker restart "$C" >/dev/null; sleep 2; esperar
sqlfile sql/01-colector-y-vista.sql
resp <<'R'
1. **¿Por qué `logging_collector` requiere reinicio y `log_statement` solo recarga?** El colector es un proceso que el servidor lanza al arrancar; `log_statement` es solo un valor que cada sesión consulta, así que basta releer la configuración.
2. **Ventaja de leer la bitácora con SQL:** funciona igual en cualquier despliegue y se puede filtrar con SQL/regex. **Riesgo:** quien pueda leer `dba.bitacora` (o usar `pg_read_file`) ve todo el archivo, incluidos secretos y datos personales, y `pg_read_file` puede leer otros archivos del servidor.
3. **¿Quién debería consultarla?** Solo el DBA o un rol de custodia/auditoría autorizado; nunca la aplicación ni los analistas (por eso `REVOKE ALL ... FROM PUBLIC`).
R

# ---------- Actividad 3 ----------
ev_start 03-incidente-sin-bitacora.md "Actividad 3 — El incidente sin bitácora" "3"
netsql app_ventas "$P_VENTAS" app-ventas-web "UPDATE clientes SET rfc = 'GAMA780912XXX' WHERE id = 3"
sleep 1
sqladm <<'SQL'
SELECT linea FROM dba.bitacora
WHERE linea ILIKE '%update%' OR linea LIKE '%app_ventas%';
SQL
resp <<'R'
1. **¿Se puede demostrar quién modificó el RFC?** No: no hay ninguna línea del cambio ni de la conexión.
2. **¿Se puede demostrar que no fue `soporte_ana`?** Tampoco. Solo se sabe que, por privilegios, ella solo tenía SELECT; pero sin bitácora no hay evidencia de lo ocurrido.
3. **¿Los privilegios impidieron el cambio?** No, y no debían: `app_ventas` tiene UPDATE por su función. El control de acceso dice quién *puede*, no deja evidencia de quién *lo hizo*.
4. **Qué debía estar configurado antes:** logging_collector, log_connections/log_disconnections, un `log_line_prefix` con `%u %d %a %h`, `log_statement` en `mod` (o más) y la auditoría a nivel de dato.
R

# ---------- Actividad 4 ----------
ev_start 04-configuracion-bitacora.md "Actividad 4 — Configurar la bitácora" "4"
sqlfile sql/02-configuracion-bitacora.sql
reload_wait
sqladm <<'SQL'
SELECT name, setting, source, sourcefile
FROM pg_settings
WHERE name IN ('log_connections','log_line_prefix','log_statement');
SQL
sqladm <<'SQL'
SELECT num, linea FROM dba.bitacora ORDER BY num DESC LIMIT 6;
SQL
resp <<'R'
- Las sentencias `ALTER SYSTEM` no aparecen porque cuando se ejecutaron `log_statement` valía `none`.
- Sí aparece `parameter ... changed to ...`, registrado por el proceso principal (PID 1) al recargar.
1. **¿Por qué lo registra el proceso principal y no tu sesión?** Porque quien relee la configuración y detecta el cambio es el proceso principal (postmaster); tu sesión solo envía la señal de recarga.
2. **Si alguien ejecuta `ALTER SYSTEM SET log_statement = 'none'`:** quedaría el cambio de parámetro (y la sentencia si el nivel vigente era ddl/mod al ejecutarla); lo que se pierde es el registro de las sentencias *posteriores*.
3. **¿Por qué no editar `postgresql.auto.conf` a mano?** Un error de sintaxis o valor inválido puede impedir el arranque o dejar cambios sin rastro; `ALTER SYSTEM` valida y deja registro.
R

# ---------- Actividad 5 ----------
ev_start 05-accesos.md "Actividad 5 — Accesos exitosos y fallidos" "5"
netsql app_ventas incorrecta "" "SELECT 1"
netsql usuario_inexistente x "" "SELECT 1"
netsql app_ventas "$P_VENTAS" app-ventas-web "SELECT count(*) FROM clientes"
sleep 1
sqladm <<'SQL'
SELECT linea FROM dba.bitacora WHERE linea LIKE '%client=127.0.0.1%' ORDER BY num;
SQL
say "Conteo de intentos fallidos por usuario (pregunta 4):"
sqladm <<'SQL'
SELECT substring(linea from 'user=(\S+)') AS usuario, count(*) AS fallos
FROM dba.bitacora
WHERE linea LIKE '%FATAL:  password authentication failed%'
GROUP BY 1 ORDER BY 2 DESC;
SQL
say "### 11.1 Lectura campo por campo (ejemplo: línea FATAL)"
say "| Campo | Valor | Significado |\n|---|---|---|\n| Fecha y hora | ver línea FATAL | Momento exacto con milisegundos y zona (UTC) |\n| PID | ver línea | Proceso/sesión; agrupa las líneas de una misma conexión |\n| Usuario | app_ventas | Rol que el cliente presentó (no prueba quién es la persona) |\n| Base de datos | comercial | Base solicitada |\n| Aplicación | [unknown] | Aún no establecida durante una autenticación fallida |\n| Cliente | 127.0.0.1 | IP origen (aquí, el propio equipo/contenedor) |\n| Severidad | FATAL | La conexión se terminó |\n| Mensaje | password authentication failed | Motivo del rechazo |\n| Regla aplicada | pg_hba.conf línea N | Regla host que coincidió (ver DETAIL) |"
resp <<'R'
1. **¿Prueba que la aplicación de ventas intentó entrar?** No. Prueba que alguien presentó el nombre `app_ventas` desde esa IP; el nombre lo escribe el cliente y podría ser otra persona, script o atacante.
2. **Rol inexistente:** el log guarda `DETAIL: Role "..." does not exist`. Al cliente se le da el mismo mensaje genérico para no revelar si un usuario existe (evita enumeración de usuarios); el detalle queda solo para el administrador.
3. **`app=[unknown]` vs `app=app-ventas-web`:** `application_name` se aplica al completar el inicio de sesión; en el intento fallido la sesión no llegó a establecerse, y en la desconexión el valor ya estaba vigente.
4. **Fuerza bruta:** muchos `FATAL: password authentication failed` seguidos, del mismo usuario o desde la misma IP en poco tiempo (o muchos usuarios distintos desde una IP). La consulta de conteo por usuario está arriba.
R

# ---------- Actividad 6 ----------
ev_start 06-privilegios-estructura.md "Actividad 6 — Cambios de privilegios y estructura" "6"
sqlfile sql/03-privilegios-estructura.sql
sleep 1
sqladm <<'SQL'
SELECT linea FROM dba.bitacora WHERE linea LIKE '%statement:%' ORDER BY num;
SQL
say "Para la exportación final se sustituye la contraseña \`Temporal_Practica_2026\` por \`<REDACTED>\`. **Revisa que este .md no exponga secretos reales antes de subirlo** (aquí es una contraseña de práctica)."
resp <<'R'
1. **Tipo de evento:** REVOKE y GRANT = *privilegio*; ALTER TABLE = *estructura* (CREATE ROLE/DROP ROLE también son privilegio).
2. **¿Por qué GRANT/REVOKE se registran con `ddl`?** Porque `log_statement = ddl` incluye CREATE/ALTER/DROP y también GRANT, REVOKE y COMMENT.
3. **¿Quién debería leer la bitácora si contiene contraseñas?** Solo el DBA/custodio autorizado. Se relaciona con la gestión de secretos de la Unidad II: no escribir contraseñas en SQL (usar `\password`, que envía un hash SCRAM), y rotar cualquier secreto que haya quedado en una bitácora.
R

# ---------- Actividad 7 ----------
ev_start 07-modificaciones.md "Actividad 7 — ddl frente a mod" "7"
say "### Con log_statement = 'ddl'"
netsql app_ventas "$P_VENTAS" app-ventas-web "UPDATE clientes SET rfc = 'GAMA780912XYZ' WHERE id = 3"
sleep 1
sqladm <<'SQL'
SELECT linea FROM dba.bitacora WHERE linea LIKE '%user=app_ventas%' ORDER BY num DESC LIMIT 3;
SQL
say "### Cambio a log_statement = 'mod'"
sqladm <<'SQL'
ALTER SYSTEM SET log_statement = 'mod';
SELECT pg_reload_conf();
SQL
reload_wait
netsql app_ventas "$P_VENTAS" app-ventas-web "UPDATE clientes SET telefono = '6679990000' WHERE id = 3" "SELECT nombre, rfc FROM clientes WHERE id = 3"
sleep 1
sqladm <<'SQL'
SELECT linea FROM dba.bitacora
WHERE linea LIKE '%log_statement%' OR linea LIKE '%user=app_ventas%statement:%'
ORDER BY num;
SQL
resp <<'R'
- Con `ddl` aparecen conexión y desconexión de `app_ventas`, pero no el UPDATE.
- Con `mod` aparece quién, cuándo, desde dónde, qué aplicación y qué sentencia. El SELECT del RFC no aparece. Tampoco aparece el valor anterior del teléfono.
1. **¿Qué nivel habría registrado la lectura del RFC?** `all`. En un servidor con miles de consultas por minuto el costo sería enorme en volumen, almacenamiento, rendimiento y datos sensibles dentro de la bitácora.
2. **¿Qué le falta para revertir con certeza?** El valor anterior del dato: la bitácora muestra qué se escribió, no qué había antes (se resuelve con la tabla de auditoría de la Parte B).
R

# ---------- Actividad 8 ----------
ev_start 08-errores.md "Actividad 8 — Errores y operaciones rechazadas" "8"
netsql soporte_ana "$P_SOPORTE" "" "DELETE FROM clientes WHERE id = 5"
sqladm <<'SQL'
DROP ROLE soporte_ana;
SQL
sleep 1
sqladm <<'SQL'
SELECT linea FROM dba.bitacora
WHERE linea ~ '(ERROR|STATEMENT|DETAIL):  (permission|privileges|role|DELETE|DROP)'
ORDER BY num;
SQL
resp <<'R'
1. **¿Hubo daño?** No, el servidor rechazó el DELETE. Aun así debe auditarse: es un intento de operación no autorizada (cuenta mal usada, comprometida o abuso).
2. **Autorización vs. autenticación:** la autenticación (Actividad 5) falla al probar *quién eres* y no se crea sesión; la autorización falla cuando ya estás autenticado pero *no tienes permiso* para esa operación.
3. **`DROP ROLE` fallido:** antes de dar de baja a un usuario hay que retirar sus privilegios y reasignar/eliminar sus objetos (`REVOKE`, `REASSIGN OWNED`, `DROP OWNED`).
R

# ---------- Actividad 9 ----------
ev_start 09-pg-stat-activity.md "Actividad 9 — Sesiones activas con pg_stat_activity" "9"
docker exec -i "$C" psql "postgresql://soporte_ana:$P_SOPORTE@127.0.0.1/comercial?application_name=reporte-mensual" -X -c "SELECT pg_sleep($SLEEP_S)" >/dev/null 2>&1 &
sleep 4
PID="$(docker exec -i "$C" psql -U postgres -d comercial -Atc "SELECT pid FROM pg_stat_activity WHERE usename='soporte_ana' AND application_name='reporte-mensual' LIMIT 1")"
say "Sesión de larga duración: \`SELECT pg_sleep($SLEEP_S)\` como soporte_ana con application_name=reporte-mensual (la guía usa 90 s). PID observado: **${PID:-?}**."
say "### Mientras se ejecuta"
sqladm <<'SQL'
SELECT pid, usename, application_name, client_addr, backend_start, state, left(query, 30) AS query
FROM pg_stat_activity WHERE backend_type = 'client backend';
SQL
sqladm <<SQL
SELECT linea FROM dba.bitacora WHERE linea LIKE '%[${PID:-0}]%' ORDER BY num;
SQL
wait; sleep 2
say "### Después de que termina el reporte"
sqladm <<'SQL'
SELECT pid, usename, application_name, client_addr, backend_start, state, left(query, 30) AS query
FROM pg_stat_activity WHERE backend_type = 'client backend';
SQL
sqladm <<SQL
SELECT linea FROM dba.bitacora WHERE linea LIKE '%[${PID:-0}]%' ORDER BY num;
SQL
resp <<'R'
1. **Columna que relaciona sesión y bitácora:** `pid` (aparece como `[pid]` en cada línea).
2. **Después de terminar el reporte:** solo la bitácora conserva evidencia de que existió; `pg_stat_activity` muestra únicamente sesiones vivas (fotografía, no historia).
3. **`client_addr` vacío en el administrador:** se conectó por socket Unix local, sin dirección IP.
R

# ---------- PARTE B ----------
ev_start 10-diseno-auditoria.md "Actividad 10 — Diseñar y crear el registro de auditoría" "10"
say "| Campo | Tipo | ¿Qué pregunta responde? | ¿Nulo? ¿Por qué? |\n|---|---|---|---|\n| id_evento | BIGSERIAL | Identifica y ordena cada evento (referencia en el informe) | No: clave primaria |\n| momento | TIMESTAMPTZ | ¿Cuándo? | No: todo evento tiene hora |\n| usuario_sesion | TEXT | ¿Quién? (rol autenticado) | No: siempre existe |\n| usuario_efectivo | TEXT | Con qué privilegios corrió (propietario en SECURITY DEFINER) | No |\n| aplicacion | TEXT | ¿Desde qué aplicación? | Sí: lo declara el cliente y puede estar vacío |\n| ip_cliente | INET | ¿Desde qué equipo? | Sí: NULL en conexiones por socket local |\n| operacion | TEXT | ¿Qué tipo de cambio? | No |\n| id_cliente | BIGINT | ¿Qué registro? | Sí: por si se auditan eventos sin fila concreta |\n| valores_antes | JSONB | ¿Qué valor tenía antes? | Sí: NULL en INSERT |\n| valores_despues | JSONB | ¿Qué valor quedó? | Sí: NULL en DELETE |"
sqlfile sql/04-esquema-auditoria.sql
resp <<'R'
1. **¿Por qué `TIMESTAMPTZ`?** Guarda un instante absoluto, sin ambigüedad de zona horaria ni de horario de verano, lo que permite correlacionar con otras fuentes.
2. **¿Por qué el registro completo en JSONB?** Conserva el estado completo aunque `clientes` cambie de estructura, y permite comparar cualquier campo o restaurar el registro.
3. **La tabla contiene RFC:** es dato personal; debe clasificarse al menos como `clientes`, con acceso solo para DBA/auditor, y entrar en la política de retención y minimización.
R

ev_start 11-funcion-disparador.md "Actividad 11 — Función y disparador" "11"
sqlfile sql/05-funcion-disparador.sql
sleep 1
sqladm <<'SQL'
SELECT linea FROM dba.bitacora WHERE linea ~ 'statement: (CREATE|REVOKE)' ORDER BY num DESC LIMIT 8;
SQL
resp <<'R'
1. **¿Por qué `REVOKE ALL ON FUNCTION ... FROM PUBLIC`?** Mínimo privilegio: nadie debe poder invocar/usar la función de auditoría; el disparador funciona igual para `app_ventas` porque no se exige EXECUTE al dispararse.
2. **Hipótesis sin SECURITY DEFINER:** la función correría con privilegios de `app_ventas`, que no puede escribir en el esquema `auditoria`; el UPDATE fallaría con `permission denied`.
3. **¿Quedó registrada la creación?** Sí, porque `log_statement = mod` incluye las sentencias `ddl` (CREATE SCHEMA/TABLE/FUNCTION/TRIGGER).
R

ev_start 11-incidente-auditado.md "Actividad 12 — El incidente auditado" "12"
netsql app_ventas "$P_VENTAS" app-ventas-web "UPDATE clientes SET rfc = 'GAMA780912ZZZ' WHERE id = 3"
netsql app_ventas "$P_VENTAS" "" "SELECT * FROM auditoria.cambios_clientes"
sqladm <<'SQL'
\x
SELECT id_evento, momento, usuario_sesion, usuario_efectivo, aplicacion, ip_cliente, operacion, id_cliente
FROM auditoria.cambios_clientes ORDER BY id_evento;
\x
SQL
sqlfile sql/06-campos-modificados.sql
resp <<'R'
1. **Hipótesis vs. resultado:** sin SECURITY DEFINER el UPDATE habría fallado; con él funciona. `usuario_efectivo = postgres` (propietario de la función) y `usuario_sesion = app_ventas` (quién provocó el cambio).
2. **Restaurar el valor anterior:** `UPDATE clientes SET rfc = 'GAMA780912XYZ' WHERE id = 3;`
3. **¿`aplicacion` o `ip_cliente`?** `ip_cliente` aporta más valor porque la ve el servidor; `aplicacion` la declara el propio cliente y es fácil de falsificar. (La IP puede ser de un NAT o proxy.)
R

ev_start 12-altas-bajas.md "Actividad 13 — Altas y bajas" "13"
sqladm <<'SQL'
INSERT INTO clientes (nombre, correo, rfc, edad, ciudad, codigo_postal)
VALUES ('Pedro Ruiz', 'pedro.ruiz@example.test', 'RUPE950101AAA', 30, 'Guasave', '81000');
DELETE FROM clientes WHERE nombre = 'Pedro Ruiz';

SELECT id_evento, usuario_sesion, aplicacion, ip_cliente, operacion, id_cliente,
       valores_antes ->> 'rfc' AS rfc_antes, valores_despues ->> 'rfc' AS rfc_despues
FROM auditoria.cambios_clientes ORDER BY id_evento;
SQL
resp <<'R'
1. **Evidencia de que Pedro Ruiz existió:** `auditoria.cambios_clientes` (el DELETE conserva todo el registro en `valores_antes`).
2. **`ip_cliente` vacía:** la sesión del administrador es local por socket Unix, sin IP.
3. **Conflicto con la retención:** la política pide eliminar datos innecesarios, pero la auditoría conserva una copia con datos personales (RFC). Debe resolverlo el responsable de datos/cumplimiento con el área legal, definiendo una retención propia para la auditoría y minimizando lo que se guarda.
R

# ---------- Actividad 14 ----------
ev_start 13-manipulacion.md "Actividad 14 — Intentar manipular la auditoría" "14"
netsql app_ventas "$P_VENTAS" app-ventas-web "DELETE FROM auditoria.cambios_clientes" "ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes"
say "### Desde el administrador"
sqladm <<'SQL'
ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes;
UPDATE clientes SET rfc = 'GAMA780912GHI' WHERE id = 3;
ALTER TABLE clientes ENABLE TRIGGER trg_auditoria_clientes;
SELECT count(*) FROM auditoria.cambios_clientes;
SQL
sleep 1
sqladm <<'SQL'
SELECT linea FROM dba.bitacora
WHERE linea ~ 'statement: (ALTER TABLE clientes (DIS|EN)ABLE|UPDATE clientes SET rfc = .GAMA780912GHI)'
ORDER BY num;
SQL
resp <<'R'
1. **Evidencia de un cambio sin auditar:** en la bitácora aparecen DISABLE TRIGGER, el UPDATE y ENABLE TRIGGER, pero no existe la fila correspondiente en `auditoria.cambios_clientes` (el conteo no aumentó).
2. **Control administrativo:** separar a quien opera la base de quien custodia la evidencia, doble autorización para cambios sobre el disparador, revisión periódica, y envío de bitácoras a un sistema externo administrado por otra área.
3. **Separación de funciones (Unidad II):** ningún rol debe concentrar operar y auditar; un administrador con control total puede desactivar los controles internos, por eso la custodia debe ser externa.
R

# ---------- Actividad 15 ----------
ev_start 14-limites.md "Actividad 15 — Límites: lecturas y volumen" "15"
netsql soporte_ana "$P_SOPORTE" "" "SELECT nombre, rfc, telefono FROM clientes WHERE id = 3"
sqladm <<'SQL'
UPDATE clientes SET segmento = 'regular';
SQL
sleep 1
sqladm <<'SQL'
SELECT count(*) AS lineas_bitacora FROM dba.bitacora
WHERE linea LIKE '%statement: UPDATE clientes SET segmento%';
SELECT operacion, count(*) FROM auditoria.cambios_clientes GROUP BY operacion ORDER BY operacion;
SELECT count(*) AS lecturas_soporte FROM dba.bitacora
WHERE linea LIKE '%user=soporte_ana%SELECT nombre, rfc%';
SQL
resp <<'R'
1. **UPDATE sin WHERE sobre 1 000 000 de filas:** una sola línea en la bitácora, pero un millón de filas en la auditoría (crecimiento de tabla, E/S, WAL y tiempo del UPDATE).
2. **¿Quién autoriza depurar `auditoria.cambios_clientes`?** Un responsable de seguridad/cumplimiento junto con el área legal y el DBA, con aprobación documentada; nunca la aplicación ni el DBA por sí solo.
3. **¿Por qué `log_statement = 'all'` crea un nuevo depósito de datos sensibles?** Porque registra consultas completas con valores literales (RFC, teléfonos, secretos) sin los controles de la tabla original.
R

# ---------- Actividad 16 ----------
ev_start 16-exportacion.md "Actividad 16 — Exportar y conservar la bitácora" "16"
docker exec -i "$C" psql -U postgres -d comercial -X -At -c "SELECT replace(pg_read_file(pg_current_logfile()), 'Temporal_Practica_2026', '<REDACTED>')" > evidencias/bitacora-lab01.log
if command -v sha256sum >/dev/null 2>&1; then sha256sum evidencias/bitacora-lab01.log > evidencias/bitacora-lab01.sha256; else shasum -a 256 evidencias/bitacora-lab01.log > evidencias/bitacora-lab01.sha256; fi
say "Comando de exportación (secreto sustituido por \`<REDACTED>\` antes de salir del servidor):"
{ echo '```bash'; echo "psql -U postgres -d comercial -At -c \"SELECT replace(pg_read_file(pg_current_logfile()), 'Temporal_Practica_2026', '<REDACTED>')\" > evidencias/bitacora-lab01.log"; echo '```'; echo 'Hash SHA-256:'; echo; echo '```text'; cat evidencias/bitacora-lab01.sha256; echo '```'; echo; echo "Comprobación de que no quedó el secreto: \`grep -c Temporal_Practica_2026\` = $(grep -c 'Temporal_Practica_2026' evidencias/bitacora-lab01.log)"; } >> "$EV"
resp <<'R'
1. **¿SHA-256 impide modificar la bitácora?** No. Permite *demostrar* si el archivo cambió respecto al momento en que se calculó el hash.
2. **¿Dónde guardar el hash?** Fuera del servidor y bajo otra custodia (repositorio, sistema de bitácoras o tercero), para que quien altere el log no pueda alterar también el hash.
3. **Riesgos de conservar la bitácora solo en el servidor que la produce:** quien lo comprometa puede borrarla o alterarla; se pierde si el servidor falla o se reinstala; no hay separación entre quien opera y quien custodia.
4. **Retención propuesta:** escribe tu cifra y criterio (p. ej., 12 meses en línea y archivo posterior, según obligaciones legales, utilidad en investigaciones, costo y riesgo de conservar datos personales). No existe cifra única correcta.
R

# ---------- Actividad 17: material para la cronología ----------
ev_start 15-cronologia.md "Actividad 17 — Cronología y respuestas a Dirección" "17"
say "Material base extraído de la bitácora y de la tabla de auditoría (úsalo para armar tu tabla; **la cronología y la interpretación son tuyas**)."
sqladm <<'SQL'
SELECT num, left(linea, 230) AS linea
FROM dba.bitacora
WHERE linea ~ '(parameter|connection authorized|FATAL|ERROR|statement:)'
ORDER BY num;
SQL
sqladm <<'SQL'
SELECT id_evento, momento, usuario_sesion, aplicacion, ip_cliente, operacion, id_cliente,
       valores_antes ->> 'rfc' AS rfc_antes, valores_despues ->> 'rfc' AS rfc_despues,
       valores_antes ->> 'telefono' AS tel_antes, valores_despues ->> 'telefono' AS tel_despues
FROM auditoria.cambios_clientes ORDER BY id_evento;
SQL
say "### Tu cronología (mínimo 8 eventos)\n\n| # | Fecha y hora | Usuario | Cliente | Tipo de evento | Qué ocurrió | ¿Exitoso? | Fuente (línea o id_evento) |\n|---|---|---|---|---|---|---|---|\n| 1 | | | | Configuración | | | |\n| 2 | | | | Acceso | | | |\n| 3 | | | | Privilegio | | | |\n| 4 | | | | Estructura | | | |\n| 5 | | | | Datos | | | |\n| 6 | | | | Error | | | |\n| 7 | | | | | | | |\n| 8 | | | | | | | |"
say "### Respuestas a Dirección (solo con evidencia; si no hay: escribe «No hay evidencia» y explica por qué)\n\n1. ¿Quién cambió el RFC? Actividad 3: _____ · Actividad 7: _____ · Actividad 12: _____ · Actividad 14: _____\n2. ¿Quién cambió el teléfono? _____\n3. ¿Hubo accesos fallidos? ¿De qué usuarios y desde dónde? _____\n4. ¿Qué valor tenía el RFC antes de cada cambio? _____\n\n_Pistas:_ el cambio de la Actividad 3 ocurrió antes de activar la bitácora y la auditoría (no hay evidencia de él); los de las Actividades 7 (RFC), 12 y 14 tienen distinta cobertura según el nivel de log_statement y si el disparador estaba activo."

echo
echo "Listo. Revisa evidencias/*.md, bitacora-lab01.log y bitacora-lab01.sha256."
echo "Pendiente de tu parte: completar 15-cronologia.md, informe.md, y (opcional) Parte C."
