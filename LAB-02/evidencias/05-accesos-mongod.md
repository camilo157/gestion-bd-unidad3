# Actividad 5 — Accesos en la bitácora de mongod

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 5
- **Fecha de ejecución:** 2026-11-15 22:35:53 HMM
- **Nota:** en cada bloque de código, `bitacora()` es la función auxiliar de la sección 6.4 (definida al inicio de cada sesión).

```bash
mongosh "mongodb://app_ventas:<REDACTED>@127.0.0.1:27017/comercial" --quiet --eval "db.clientes.countDocuments()"
```
Resultado:

```text
MongoServerError: Authentication failed.
```

```bash
mongosh "mongodb://usuario_inexistente:<REDACTED>@127.0.0.1:27017/comercial" --quiet --eval "db.clientes.countDocuments()"
```
Resultado:

```text
MongoServerError: Authentication failed.
```

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
printjson(bitacora()
  .filter(e => e.c === "ACCESS" && e.msg === "Failed to authenticate")
  .map(e => ({ t: e.t, id: e.id, ctx: e.ctx, user: e.attr.user, client: e.attr.client, error: e.attr.error, result: e.attr.result, app: e.attr.doc?.application?.name })))
```
Resultado:

```text
[
  {
    t: {
      '$date': '2026-11-16T05:35:54.528+00:00'
    },
    id: 5286307,
    ctx: 'conn66',
    user: 'app_ventas',
    client: '127.0.0.1:35806',
    error: 'AuthenticationFailed: SCRAM authentication failed, storedKey mismatch',
    result: 18,
    app: 'mongosh 2.13.0'
  },
  {
    t: {
      '$date': '2026-11-16T05:35:55.099+00:00'
    },
    id: 5286307,
    ctx: 'conn68',
    user: 'usuario_inexistente',
    client: '127.0.0.1:35824',
    error: 'UserNotFound: Could not find user "usuario_inexistente" for db "comercial"',
    result: 11,
    app: 'mongosh 2.13.0'
  },
  {
    t: {
      '$date': '2026-11-16T05:35:55.101+00:00'
    },
    id: 5286307,
    ctx: 'conn68',
    user: 'usuario_inexistente',
    client: '127.0.0.1:35824',
    error: 'UserNotFound: Could not find user "usuario_inexistente" for db "comercial"',
    result: 11,
    app: 'mongosh 2.13.0'
  }
]
```

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
printjson(bitacora()
  .filter(e => e.msg === "Successfully authenticated" && e.attr.user === "app_ventas")
  .slice(-1)
  .map(e => ({ t: e.t, id: e.id, ctx: e.ctx, client: e.attr.client, result: e.attr.result, app: e.attr.doc?.application?.name })))
```
Resultado:

```text
[
  {
    t: {
      '$date': '2026-11-16T05:35:53.193+00:00'
    },
    id: 5286306,
    ctx: 'conn60',
    client: '127.0.0.1:38974',
    result: 0,
    app: 'app-ventas-web'
  }
]
```


## Respuestas e interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **¿Qué distingue un acceso fallido de uno exitoso?** El mensaje (`Failed to authenticate` frente a `Successfully authenticated`), el `id` del evento y `attr.result` (0 = éxito; distinto de 0 = fallo, p. ej. 18 contraseña incorrecta y 11 usuario inexistente).
2. **Contraseña incorrecta vs. usuario inexistente:** el primero es `AuthenticationFailed` (no coincide la credencial) y el segundo `UserNotFound`. El cliente recibe el mismo `Authentication failed` en ambos para no revelar si un usuario existe (evita enumeración de usuarios); el detalle queda solo en la bitácora.
3. **¿Por qué la aplicación del intento fallido es `mongosh x.y.z` y no `app-ventas-web`?** Porque `application.name` lo declara el cliente; en esos intentos no se indicó `appName`, así que `mongosh` usa su nombre y versión por defecto. Un cliente puede declarar cualquier nombre, por lo que no es evidencia fuerte de identidad.

