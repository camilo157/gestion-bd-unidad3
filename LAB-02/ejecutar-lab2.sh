#!/usr/bin/env bash
# LAB-02 — Trazabilidad en MongoDB Community
# Monta MongoDB 7 en Docker, ejecuta las actividades 1-10 y genera evidencias/*
# Uso (Git Bash):  ESTUDIANTE="Tu Nombre" ./ejecutar-lab2.sh
# Opciones: RECREAR=1 (borra el contenedor si existe), C=nombre, PUERTO=27017
set -u
export MSYS_NO_PATHCONV=1
cd "$(dirname "$0")"
ESTUDIANTE="${ESTUDIANTE:-<TU NOMBRE>}"
C="${C:-dba-u3-mongo}"
PUERTO="${PUERTO:-27017}"
ADM_URI="mongodb://admin:Admin_Practica_2026@127.0.0.1:27017/comercial?authSource=admin"
APP_URI="mongodb://app_ventas:Ventas_Practica_2026@127.0.0.1:27017/comercial?appName=app-ventas-web"
ADM_SHOWN="mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
APP_SHOWN="mongodb://app_ventas:<REDACTED>@127.0.0.1:27017/comercial?appName=app-ventas-web"
PRE='function bitacora() { return db.adminCommand({ getLog: "global" }).log.map(l => JSON.parse(l)); }; '
mkdir -p evidencias

# ---------- utilidades ----------
ev_start(){ EV="evidencias/$1"; { echo "# $2"; echo; echo "- **Estudiante:** $ESTUDIANTE"; echo "- **Actividad:** $3"; echo "- **Fecha de ejecución:** $(date '+%Y-%m-%d %H:%M:%S %Z')"; echo "- **Nota:** en cada bloque de código, \`bitacora()\` es la función auxiliar de la sección 6.4 (definida al inicio de cada sesión)."; echo; } > "$EV"; echo ">> $EV"; }
say(){ printf '\n%b\n\n' "$*" >> "$EV"; }
resp(){ { echo; echo "## Respuestas e interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)"; echo; cat; echo; } >> "$EV"; }
js_run(){ docker exec "$C" mongosh "$1" --quiet --eval "${PRE}$2" 2>&1; }
adm(){ local code; code="$(cat)"; { echo '```js'; echo "// Sesión del DBA: mongosh \"$ADM_SHOWN\""; echo "$code"; echo '```'; echo 'Resultado:'; echo; echo '```text'; js_run "$ADM_URI" "$code"; echo '```'; echo; } >> "$EV"; }
app(){ local code; code="$(cat)"; { echo '```js'; echo "// Sesión de la aplicación: mongosh \"$APP_SHOWN\""; echo "$code"; echo '```'; echo 'Resultado:'; echo; echo '```text'; js_run "$APP_URI" "$code"; echo '```'; echo; } >> "$EV"; }
mdadm(){ local code; code="$(cat)"; js_run "$ADM_URI" "$code" >> "$EV"; echo >> "$EV"; }
net_try(){ local shown="$1" uri="$2" code="$3"; { echo '```bash'; echo "mongosh \"$shown\" --quiet --eval \"$code\""; echo '```'; echo 'Resultado:'; echo; echo '```text'; docker exec "$C" mongosh "$uri" --quiet --eval "$code" 2>&1; echo '```'; echo; } >> "$EV"; }
esperar(){ for i in $(seq 1 90); do docker exec "$C" mongosh --quiet --eval 'db.runCommand({ping:1}).ok' 2>/dev/null | grep -q 1 && break; sleep 1; done; sleep 2; }
hashf(){ if command -v sha256sum >/dev/null 2>&1; then sha256sum "$@"; else shasum -a 256 "$@"; fi; }

# ---------- Despliegue (Anexo A.2) ----------
if docker ps -a --format '{{.Names}}' | grep -qx "$C"; then
  if [ "${RECREAR:-0}" = "1" ]; then docker rm -f "$C" >/dev/null; else echo "El contenedor $C ya existe. Usa RECREAR=1 para borrarlo y empezar limpio."; exit 1; fi
fi
docker run --name "$C" -p "$PUERTO:27017" -d mongo:7 --auth >/dev/null || exit 1
esperar

# ---------- 6.3 Usuarios y datos (excepción de localhost) ----------
docker exec "$C" mongosh --quiet --eval '
db = db.getSiblingDB("admin");
db.createUser({ user: "admin", pwd: "Admin_Practica_2026", roles: ["root"] });
db.auth("admin", "Admin_Practica_2026");
db = db.getSiblingDB("comercial");
db.createUser({ user: "app_ventas", pwd: "Ventas_Practica_2026", roles: [{ role: "readWrite", db: "comercial" }] });
db.clientes.insertMany([
  { _id: 1, nombre: "Ana López", correo: "ana.lopez@example.test", telefono: "6671234567", rfc: "LOAA850315ABC", edad: 41, ciudad: "Culiacán", codigo_postal: "80000" },
  { _id: 2, nombre: "Carlos Pérez", correo: "carlos.perez@example.test", telefono: "6672345678", rfc: "PECA900720DEF", edad: 35, ciudad: "Culiacán", codigo_postal: "80100" },
  { _id: 3, nombre: "María García", correo: "maria.garcia@example.test", telefono: "6673456789", rfc: "GAMA780912GHI", edad: 47, ciudad: "Mazatlán", codigo_postal: "82000" },
  { _id: 4, nombre: "Luis Torres", correo: "luis.torres@example.test", telefono: "6674567890", rfc: "TOLU920201JKL", edad: 34, ciudad: "Los Mochis", codigo_postal: "81200" },
  { _id: 5, nombre: "Laura Sánchez", correo: "laura.sanchez@example.test", telefono: "6675678901", rfc: "SALA880525MNO", edad: 38, ciudad: "Culiacán", codigo_postal: "80200" }
]);
' >/dev/null 2>&1

# ---------- Actividad 1 ----------
ev_start 01-edicion-y-limitacion.md "Actividad 1 — Lo que no existe en esta edición" "1"
say "Despliegue: contenedor Docker \`$C\` con la imagen oficial \`mongo:7\`, arrancado con \`--auth\` (Anexo A.2)."
adm <<'JS'
printjson({
  version: db.version(),
  modules: db.adminCommand({ buildInfo: 1 }).modules,
  parsed: db.serverCmdLineOpts().parsed
})
JS
say "Últimas líneas de la salida estándar del contenedor (destino de la bitácora, pues no hay \`systemLog\` configurado):"
{ echo '```bash'; echo "docker logs $C --tail 2"; echo '```'; echo '```text'; docker logs "$C" --tail 2 2>&1 | cut -c1-300; echo '```'; echo; } >> "$EV"
resp <<'R'
1. **Edición:** MongoDB Community. La evidencia es que `modules` está vacío (`[]`); en Enterprise incluiría `"enterprise"`. La auditoría nativa (`--auditDestination`) no está disponible en esta edición (REF-U3-04).
2. **Destino de la bitácora:** la salida estándar del proceso (se lee con `docker logs`). Lo sé porque `serverCmdLineOpts().parsed` no muestra ninguna sección `systemLog` con `destination: file`.
3. **Cuatro categorías de la auditoría nativa:** cambios de esquema (DDL); eventos de conjuntos de réplicas y clústeres fragmentados; autenticación y autorización; operaciones CRUD (requiere `auditAuthorizationSuccess: true`).
4. **Antes de licenciar Enterprise o migrar a Atlas** habría que evaluar: costo de licencia o de clústeres M10+, esfuerzo de migración, qué eventos se necesitan realmente, volumen y almacenamiento de la auditoría, custodia de los registros, y si un control compensatorio basta para el riesgo.
R

# ---------- Actividad 2 ----------
ev_start 02-incidente-sin-perfilado.md "Actividad 2 — El incidente sin perfilado" "2"
adm <<'JS'
db.getProfilingStatus()
JS
app <<'JS'
db.clientes.updateOne({ _id: 3 }, { $set: { rfc: "GAMA780912XXX" } })
JS
adm <<'JS'
printjson({
  documentos_en_system_profile: db.system.profile.countDocuments(),
  eventos_bitacora_con_el_valor_nuevo: bitacora().filter(e => JSON.stringify(e).includes("GAMA780912XXX")).length
})
JS
adm <<'JS'
printjson(bitacora().filter(e => JSON.stringify(e).includes("app-ventas-web")).map(e => ({ t: e.t, c: e.c, ctx: e.ctx, msg: e.msg })))
JS
resp <<'R'
1. **¿Se puede demostrar qué cambió?** No: el perfilador estaba apagado (`was: 0`) y la bitácora no registra operaciones. **¿Quién se conectó a esa hora?** Sí se ve que una sesión con `appName=app-ventas-web` se conectó y se autenticó (`Successfully authenticated`), pero eso no prueba qué hizo.
2. **¿Por qué varias conexiones (conn8, conn9...)?** `mongosh` abre una conexión para monitorear el servidor y otra de trabajo. La que se autentica y ejecuta el comando es la de trabajo; en la otra aparece `Connection not authenticating`.
R

# ---------- Actividad 3 ----------
ev_start 03-perfilador.md "Actividad 3 — Activar el perfilador y registrar operaciones" "3"
adm <<'JS'
printjson(db.setProfilingLevel(2)); printjson(db.getProfilingStatus())
JS
app <<'JS'
db.clientes.find({ ciudad: "Culiacán" }, { nombre: 1, ciudad: 1 }).toArray(); db.clientes.updateOne({ _id: 3 }, { $set: { rfc: "GAMA780912XYZ" } }); db.clientes.deleteOne({ _id: 2 });
JS
adm <<'JS'
printjson(db.system.profile.find(
  { ns: "comercial.clientes" },
  { op: 1, ns: 1, command: 1, user: 1, client: 1, appName: 1, ts: 1, millis: 1, nreturned: 1, docsExamined: 1, nModified: 1, ndeleted: 1 }
).sort({ ts: 1 }).toArray())
JS
say "### 9.1 Interpretación de los documentos (generada a partir de system.profile)"
mdadm <<'JS'
print("| # | op | Usuario | Cliente | Aplicación | Momento (UTC) | Qué hizo | Documentos afectados |");
print("|---|---|---|---|---|---|---|---|");
let n = 0;
db.system.profile.find({ ns: "comercial.clientes", user: "app_ventas@comercial" }).sort({ ts: 1 }).forEach(d => {
  n++;
  const que = d.op === "query" ? "find " + JSON.stringify(d.command.filter)
    : d.op === "update" ? "update " + JSON.stringify(d.command.q) + " " + JSON.stringify(d.command.u)
    : d.op === "remove" ? "delete " + JSON.stringify(d.command.q) : d.op;
  const afect = d.op === "query" ? "examinados " + d.docsExamined + ", devueltos " + d.nreturned
    : d.op === "update" ? "modificados " + d.nModified
    : d.op === "remove" ? "eliminados " + d.ndeleted : "";
  print("| " + n + " | " + d.op + " | " + d.user + " | " + d.client + " | " + d.appName + " | " + d.ts.toISOString() + " | " + que + " | " + afect + " |");
});
JS
# instantánea de la evidencia ANTES de borrar system.profile en la Actividad 4
docker exec "$C" mongosh "$ADM_URI" --quiet --eval 'EJSON.stringify(db.system.profile.find({}, { op: 1, ns: 1, user: 1, client: 1, appName: 1, ts: 1, "command.q": 1, "command.u": 1, "command.filter": 1 }).toArray(), null, 2)' > evidencias/system-profile-actividad3.json 2>/dev/null
say "Se guardó una copia de la evidencia en \`evidencias/system-profile-actividad3.json\` antes de borrar \`system.profile\` (Actividad 4)."
resp <<'R'
1. **¿Se sabe el RFC anterior?** No. El documento del `update` solo contiene el `$set` con el valor nuevo; `system.profile` no guarda el valor previo.
2. **¿Se sabe qué datos tenía el documento eliminado?** No. El `remove` guarda solo el filtro (`{ _id: 2 }`) y que se eliminó 1 documento, no su contenido.
3. **Nivel 2 registró la consulta (a diferencia de `log_statement = 'mod'`):** *ventaja:* permite ver quién leyó qué datos. *Riesgo:* costo de desempeño, volumen y que los filtros pueden contener datos personales, con lo que `system.profile` se vuelve otro depósito de datos sensibles.
4. **¿Por qué `user` incluye `@comercial`?** Porque una identidad en MongoDB es usuario + base donde se definió; `app_ventas@comercial` es distinto de un `app_ventas` definido en otra base.
R

# ---------- Actividad 4 ----------
ev_start 04-filtro.md "Actividad 4 — Reducir el volumen con un filtro" "4"
adm <<'JS'
db.setProfilingLevel(0); db.system.profile.drop(); printjson(db.setProfilingLevel(1, { filter: { op: { $in: ["insert", "update", "remove"] } } })); printjson(db.getProfilingStatus())
JS
app <<'JS'
db.clientes.find({ _id: 1 }).toArray(); db.clientes.updateOne({ _id: 1 }, { $set: { telefono: "6670000000" } })
JS
adm <<'JS'
printjson(db.system.profile.find({}, { op: 1, ns: 1, user: 1, appName: 1, "command.q": 1, "command.u": 1, ts: 1 }).toArray())
JS
resp <<'R'
1. **¿Qué se perdió y qué se ganó?** Se perdió la evidencia de lecturas (las consultas `query`) y de otros tipos de operación; además, con un filtro dejan de usarse `slowms` y `sampleRate`. Se ganó menos volumen, menor costo de rendimiento, menos datos personales expuestos en `system.profile` y más tiempo de vida de la evidencia en una colección de solo 1 MB.
2. **Filtro solo para la colección `clientes`:** `{ ns: "comercial.clientes", op: { $in: ["insert", "update", "remove"] } }`.
R

# ---------- Actividad 5 ----------
ev_start 05-accesos-mongod.md "Actividad 5 — Accesos en la bitácora de mongod" "5"
net_try "mongodb://app_ventas:<REDACTED>@127.0.0.1:27017/comercial" "mongodb://app_ventas:incorrecta@127.0.0.1:27017/comercial" "db.clientes.countDocuments()"
net_try "mongodb://usuario_inexistente:<REDACTED>@127.0.0.1:27017/comercial" "mongodb://usuario_inexistente:x@127.0.0.1:27017/comercial" "db.clientes.countDocuments()"
adm <<'JS'
printjson(bitacora()
  .filter(e => e.c === "ACCESS" && e.msg === "Failed to authenticate")
  .map(e => ({ t: e.t, id: e.id, ctx: e.ctx, user: e.attr.user, client: e.attr.client, error: e.attr.error, result: e.attr.result, app: e.attr.doc?.application?.name })))
JS
adm <<'JS'
printjson(bitacora()
  .filter(e => e.msg === "Successfully authenticated" && e.attr.user === "app_ventas")
  .slice(-1)
  .map(e => ({ t: e.t, id: e.id, ctx: e.ctx, client: e.attr.client, result: e.attr.result, app: e.attr.doc?.application?.name })))
JS
resp <<'R'
1. **¿Qué distingue un acceso fallido de uno exitoso?** El mensaje (`Failed to authenticate` frente a `Successfully authenticated`), el `id` del evento y `attr.result` (0 = éxito; distinto de 0 = fallo, p. ej. 18 contraseña incorrecta y 11 usuario inexistente).
2. **Contraseña incorrecta vs. usuario inexistente:** el primero es `AuthenticationFailed` (no coincide la credencial) y el segundo `UserNotFound`. El cliente recibe el mismo `Authentication failed` en ambos para no revelar si un usuario existe (evita enumeración de usuarios); el detalle queda solo en la bitácora.
3. **¿Por qué la aplicación del intento fallido es `mongosh x.y.z` y no `app-ventas-web`?** Porque `application.name` lo declara el cliente; en esos intentos no se indicó `appName`, así que `mongosh` usa su nombre y versión por defecto. Un cliente puede declarar cualquier nombre, por lo que no es evidencia fuerte de identidad.
R

# ---------- Actividad 6 ----------
ev_start 06-correlacion.md "Actividad 6 — Correlacionar un cambio de configuración con su autor" "6"
adm <<'JS'
printjson(bitacora().filter(e => e.msg === "Profiler settings changed").map(e => ({ t: e.t, ctx: e.ctx, msg: e.msg, attr: e.attr })))
JS
say "Autenticación de la misma conexión (ctx) que cambió la configuración por última vez (se toma automáticamente el ctx del último evento):"
adm <<'JS'
const cambios = bitacora().filter(e => e.msg === "Profiler settings changed");
const ult = cambios[cambios.length - 1];
print("ctx del último cambio de configuración: " + (ult ? ult.ctx : "no encontrado"));
if (ult) printjson(bitacora().filter(e => e.ctx === ult.ctx && e.msg === "Successfully authenticated").map(e => ({ t: e.t, ctx: e.ctx, user: e.attr.user, db: e.attr.db, client: e.attr.client })))
JS
resp <<'R'
1. **¿Qué usuario cambió la configuración del perfilador?** El que aparezca en la autenticación de la misma `ctx` (en este laboratorio, `admin`). Lo demuestran dos eventos: `Profiler settings changed` (con `from`/`to` y la `ctx`) y `Successfully authenticated` de esa misma `ctx`.
2. **Condición para que la correlación sea válida:** que ambos eventos pertenezcan a la misma ejecución del servidor y a la misma conexión; los números de conexión vuelven a empezar tras un reinicio, y `getLog` solo conserva los 1024 eventos más recientes (la autenticación podría haber salido de la memoria).
3. **¿Por qué importa que se registre el cambio de configuración del propio registro?** Porque quien controla el mecanismo puede apagarlo o reducirlo y crear un hueco de evidencia; el registro del cambio permite detectarlo y atribuirlo.
R

# ---------- Actividad 7 ----------
ev_start 07-privilegios-control-compensatorio.md "Actividad 7 — Cambios de privilegios: el límite más importante" "7"
say "### Instantánea 1 (antes del cambio)"
adm <<'JS'
db.getSiblingDB("auditoria").instantaneas_privilegios.insertOne({ momento: new Date(), tomada_por: db.runCommand({ connectionStatus: 1 }).authInfo.authenticatedUsers, usuarios: db.getUsers().users.map(u => ({ user: u.user, db: u.db, roles: u.roles })) })
JS
say "### Cambio de privilegios con el perfilador en nivel 2"
adm <<'JS'
db.setProfilingLevel(2); db.grantRolesToUser("app_ventas", [{ role: "dbAdmin", db: "comercial" }])
JS
say "### Búsqueda de evidencia del cambio"
adm <<'JS'
printjson({
  perfilador: db.system.profile.countDocuments({ "command.grantRolesToUser": { $exists: true } }),
  bitacora: bitacora().filter(e => JSON.stringify(e).includes("grantRoles")).length
})
JS
say "### Instantánea 2 (después del cambio) y comparación"
adm <<'JS'
db.getSiblingDB("auditoria").instantaneas_privilegios.insertOne({ momento: new Date(), tomada_por: db.runCommand({ connectionStatus: 1 }).authInfo.authenticatedUsers, usuarios: db.getUsers().users.map(u => ({ user: u.user, db: u.db, roles: u.roles })) })
JS
adm <<'JS'
printjson(db.getSiblingDB("auditoria").instantaneas_privilegios.find({}, { _id: 0 }).sort({ momento: 1 }).toArray())
JS
say "### Revocar el rol y restablecer el filtro de la Actividad 4"
adm <<'JS'
db.revokeRolesFromUser("app_ventas", [{ role: "dbAdmin", db: "comercial" }]); printjson(db.setProfilingLevel(1, { filter: { op: { $in: ["insert", "update", "remove"] } } }))
JS
say "| Pregunta | ¿La instantánea responde? |\n|---|---|\n| ¿Cambiaron los privilegios de app_ventas? | Sí |\n| ¿Qué rol se agregó? | Sí |\n| ¿Quién lo agregó? | **No** |\n| ¿Cuándo exactamente? | **No**, solo que ocurrió entre dos instantáneas |\n\n_Nota:_ la instantánea no sustituye a la auditoría nativa: es un control compensatorio que detecta el cambio pero no lo atribuye."
resp <<'R'
1. **¿Por qué es uno de los eventos más importantes?** Porque otorgar privilegios amplía lo que alguien puede hacer (escalada de privilegios) y puede ser la preparación de un abuso o ataque; cambia toda la superficie de riesgo.
2. **Frecuencia de las instantáneas:** depende de la criticidad de los datos, la frecuencia de altas/cambios de usuarios, la ventana de detección tolerable, el costo de almacenamiento y los requisitos de cumplimiento (por ejemplo, cada hora o diario, y antes/después de cada cambio aprobado).
3. **¿Quién debería poder escribir en `auditoria.instantaneas_privilegios`?** Solo un rol o proceso de seguridad/auditoría independiente de quien administra usuarios; el DBA operativo no debería poder borrar o modificar esas instantáneas.
4. **Mensaje a Dirección (tres líneas):** «Con MongoDB Community podemos detectar que los privilegios de `app_ventas` cambiaron entre dos instantáneas, pero no podemos demostrar quién lo hizo ni a qué hora exacta. Es un control compensatorio, no una auditoría. Para atribuir el cambio se necesita auditoría nativa (Enterprise/Atlas) o controlar y registrar la administración de usuarios fuera del servidor.»
R

# ---------- Actividad 8 ----------
ev_start 08-conservacion.md "Actividad 8 — Conservación: exportar antes de perder" "8"
say "### 14.3 Exportar la bitácora (antes del reinicio, porque la memoria de getLog se vacía)"
docker exec "$C" mongosh "$ADM_URI" --quiet --eval 'db.adminCommand({ getLog: "global" }).log.join("\n")' > evidencias/bitacora-mongod.log 2>/dev/null
docker logs "$C" > evidencias/bitacora-mongod-completa.log 2>&1
{ echo '```bash'; echo "mongosh \"$ADM_SHOWN\" --quiet --eval 'db.adminCommand({ getLog: \"global\" }).log.join(\"\\n\")' > evidencias/bitacora-mongod.log"; echo "docker logs $C > evidencias/bitacora-mongod-completa.log   # historia completa (salida estándar)"; echo '```'; echo "Líneas exportadas: \`bitacora-mongod.log\` = $(wc -l < evidencias/bitacora-mongod.log), \`bitacora-mongod-completa.log\` = $(wc -l < evidencias/bitacora-mongod-completa.log). Contraseñas de práctica encontradas en los .log: **$(grep -c 'Practica_2026' evidencias/bitacora-mongod.log evidencias/bitacora-mongod-completa.log | tr '\n' ' ')**"; echo; } >> "$EV"
adm <<'JS'
print("eventos en memoria (getLog) antes del reinicio: " + bitacora().length)
JS
say "### 14.1 Reinicio del servicio: \`docker restart $C\`"
docker restart "$C" >/dev/null; sleep 2; esperar
adm <<'JS'
printjson({ nivel_perfilador: db.getProfilingStatus(), docs_en_system_profile: db.system.profile.countDocuments(), eventos_en_memoria_getLog: bitacora().length })
JS
say "### 14.2 Exportar system.profile"
docker exec "$C" mongosh "$ADM_URI" --quiet --eval 'EJSON.stringify(db.system.profile.find({}, { op: 1, ns: 1, user: 1, client: 1, appName: 1, ts: 1, "command.q": 1, "command.u": 1 }).toArray(), null, 2)' > evidencias/system-profile.json 2>/dev/null
( cd evidencias && hashf system-profile.json system-profile-actividad3.json bitacora-mongod.log bitacora-mongod-completa.log > hashes.sha256 )
{ echo '```bash'; echo "mongosh \"$ADM_SHOWN\" --quiet --eval 'EJSON.stringify(db.system.profile.find(...).toArray(), null, 2)' > evidencias/system-profile.json"; echo '```'; echo "Hashes SHA-256 (\`evidencias/hashes.sha256\`):"; echo '```text'; cat evidencias/hashes.sha256; echo '```'; echo; } >> "$EV"
resp <<'R'
1. **Tres formas de perder evidencia sin borrarla a propósito:** (a) `system.profile` es una colección limitada de 1 MB y se sobrescribe sola; (b) `getLog` vive en memoria, guarda solo 1024 eventos y se vacía al reiniciar; (c) el nivel del perfilador vuelve a 0 al reiniciar, así que se deja de registrar sin aviso; (d) si el contenedor se elimina, se pierde la salida estándar.
2. **¿Por qué el tamaño de 1 MB es un problema de conservación?** Porque la actividad normal sobrescribe la evidencia más antigua: un periodo de mucho tráfico puede borrar el rastro de un incidente reciente, y no se puede garantizar una ventana de retención.
3. **¿Por qué `getLog` sirve para interpretar pero no para conservar?** Solo devuelve los 1024 eventos más recientes de la memoria del servidor y se vacía al reiniciar: no tiene historia completa ni persistencia.
R

# ---------- Actividad 9 ----------
ev_start 09-comparacion.md "Actividad 9 — Comparar los tres escenarios" "9"
cat >> "$EV" <<'TABLA'
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
TABLA
echo ">> $EV (tabla generada)"

# ---------- Actividad 10 ----------
ev_start 10-respuesta-direccion.md "Actividad 10 — Responder a Dirección" "10"
say "Material base (extraído de \`system-profile.json\` y de la bitácora exportada). **La interpretación final es tuya.**"
{ echo '```text'; echo "== system.profile exportado (resumen) =="; docker exec "$C" mongosh "$ADM_URI" --quiet --eval 'db.system.profile.find({}, {op:1, user:1, client:1, appName:1, ts:1, "command.q":1, "command.u":1}).sort({ts:1}).forEach(d => print(d.ts.toISOString() + " | " + d.op + " | " + d.user + " | " + d.client + " | " + d.appName + " | " + JSON.stringify(d.command.q) + " " + JSON.stringify(d.command.u)))' 2>&1; echo; echo "== bitácora: autenticaciones y cambios del perfilador (recortado) =="; grep -E 'Successfully authenticated|Failed to authenticate|Profiler settings changed' evidencias/bitacora-mongod.log | cut -c1-330; echo '```'; echo; } >> "$EV"
say "### Respuestas a Dirección (solo con la evidencia; si no hay: «No hay evidencia con esta edición» + motivo técnico)\n\n1. ¿Quién cambió el RFC? Actividad 2 (XXX): _____ · Actividad 3 (XYZ): _____\n2. ¿Cuándo y desde qué aplicación? _____\n3. ¿Qué valor tenía antes? _____\n4. ¿Cambió alguien los privilegios de app_ventas? _____\n\n_Pistas:_ en la Actividad 2 el perfilador estaba apagado; en la 3 el perfilador registra usuario, cliente, aplicación y momento, pero no el valor anterior; para los privilegios solo existen las dos instantáneas."

echo
echo "Listo. Revisa evidencias/*.md, system-profile.json, bitacora-mongod.log y hashes.sha256."
echo "Pendiente de tu parte: completar 10-respuesta-direccion.md, revisar respuestas, informe.md y README.md."
