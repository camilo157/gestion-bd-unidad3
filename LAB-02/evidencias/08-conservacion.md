# Actividad 8 — Conservación: exportar antes de perder

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 8
- **Fecha de ejecución:** 2026-11-15 22:36:02 HMM
- **Nota:** en cada bloque de código, `bitacora()` es la función auxiliar de la sección 6.4 (definida al inicio de cada sesión).


### 14.3 Exportar la bitácora (antes del reinicio, porque la memoria de getLog se vacía)

```bash
mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin" --quiet --eval 'db.adminCommand({ getLog: "global" }).log.join("\n")' > evidencias/bitacora-mongod.log
docker logs dba-u3-mongo > evidencias/bitacora-mongod-completa.log   # historia completa (salida estándar)
```
Líneas exportadas: `bitacora-mongod.log` = 1310, `bitacora-mongod-completa.log` = 661. Contraseñas de práctica encontradas en los .log: **evidencias/bitacora-mongod.log:0 evidencias/bitacora-mongod-completa.log:0 **

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
print("eventos en memoria (getLog) antes del reinicio: " + bitacora().length)
```
Resultado:

```text
eventos en memoria (getLog) antes del reinicio: 675
```


### 14.1 Reinicio del servicio: `docker restart dba-u3-mongo`

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
printjson({ nivel_perfilador: db.getProfilingStatus(), docs_en_system_profile: db.system.profile.countDocuments(), eventos_en_memoria_getLog: bitacora().length })
```
Resultado:

```text
{
  nivel_perfilador: {
    was: 0,
    slowms: 100,
    sampleRate: 1,
    ok: 1
  },
  docs_en_system_profile: 2,
  eventos_en_memoria_getLog: 99
}
```


### 14.2 Exportar system.profile

```bash
mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin" --quiet --eval 'EJSON.stringify(db.system.profile.find(...).toArray(), null, 2)' > evidencias/system-profile.json
```
Hashes SHA-256 (`evidencias/hashes.sha256`):
```text
e690fc01b72825bc9d30b295af719e035a7c32a403c1c292379bc57e52d9bb8c *system-profile.json
8cf1b826227ea16a7ff99bfe5f41c23ef800e57ff57b939d40d127e9238bde21 *system-profile-actividad3.json
a5e9c08d1ef10d185a179a964c94fad34947593a29faa57a2d43c9720fcfa234 *bitacora-mongod.log
ab3bdd0116798ee1b732f290330197c62bf28205493461d58a24ea89f28b7b0e *bitacora-mongod-completa.log
```


## Respuestas e interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **Tres formas de perder evidencia sin borrarla a propósito:** (a) `system.profile` es una colección limitada de 1 MB y se sobrescribe sola; (b) `getLog` vive en memoria, guarda solo 1024 eventos y se vacía al reiniciar; (c) el nivel del perfilador vuelve a 0 al reiniciar, así que se deja de registrar sin aviso; (d) si el contenedor se elimina, se pierde la salida estándar.
2. **¿Por qué el tamaño de 1 MB es un problema de conservación?** Porque la actividad normal sobrescribe la evidencia más antigua: un periodo de mucho tráfico puede borrar el rastro de un incidente reciente, y no se puede garantizar una ventana de retención.
3. **¿Por qué `getLog` sirve para interpretar pero no para conservar?** Solo devuelve los 1024 eventos más recientes de la memoria del servidor y se vacía al reiniciar: no tiene historia completa ni persistencia.

