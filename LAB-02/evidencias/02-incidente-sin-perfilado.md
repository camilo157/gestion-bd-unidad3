# Actividad 2 — El incidente sin perfilado

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 2
- **Fecha de ejecución:** 2026-11-15 22:35:45 HMM
- **Nota:** en cada bloque de código, `bitacora()` es la función auxiliar de la sección 6.4 (definida al inicio de cada sesión).

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
db.getProfilingStatus()
```
Resultado:

```text
{ was: 0, slowms: 100, sampleRate: 1, ok: 1 }
```

```js
// Sesión de la aplicación: mongosh "mongodb://app_ventas:<REDACTED>@127.0.0.1:27017/comercial?appName=app-ventas-web"
db.clientes.updateOne({ _id: 3 }, { $set: { rfc: "GAMA780912XXX" } })
```
Resultado:

```text
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 1,
  upsertedCount: 0
}
```

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
printjson({
  documentos_en_system_profile: db.system.profile.countDocuments(),
  eventos_bitacora_con_el_valor_nuevo: bitacora().filter(e => JSON.stringify(e).includes("GAMA780912XXX")).length
})
```
Resultado:

```text
{
  documentos_en_system_profile: 0,
  eventos_bitacora_con_el_valor_nuevo: 0
}
```

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
printjson(bitacora().filter(e => JSON.stringify(e).includes("app-ventas-web")).map(e => ({ t: e.t, c: e.c, ctx: e.ctx, msg: e.msg })))
```
Resultado:

```text
[
  {
    t: {
      '$date': '2026-11-16T05:35:46.365+00:00'
    },
    c: 'NETWORK',
    ctx: 'conn21',
    msg: 'client metadata'
  },
  {
    t: {
      '$date': '2026-11-16T05:35:46.365+00:00'
    },
    c: 'ACCESS',
    ctx: 'conn21',
    msg: 'Connection not authenticating'
  },
  {
    t: {
      '$date': '2026-11-16T05:35:46.371+00:00'
    },
    c: 'NETWORK',
    ctx: 'conn22',
    msg: 'client metadata'
  },
  {
    t: {
      '$date': '2026-11-16T05:35:46.383+00:00'
    },
    c: 'ACCESS',
    ctx: 'conn22',
    msg: 'Successfully authenticated'
  },
  {
    t: {
      '$date': '2026-11-16T05:35:46.505+00:00'
    },
    c: 'NETWORK',
    ctx: 'conn23',
    msg: 'client metadata'
  },
  {
    t: {
      '$date': '2026-11-16T05:35:46.506+00:00'
    },
    c: 'NETWORK',
    ctx: 'conn24',
    msg: 'client metadata'
  },
  {
    t: {
      '$date': '2026-11-16T05:35:46.518+00:00'
    },
    c: 'ACCESS',
    ctx: 'conn23',
    msg: 'Successfully authenticated'
  },
  {
    t: {
      '$date': '2026-11-16T05:35:46.518+00:00'
    },
    c: 'ACCESS',
    ctx: 'conn24',
    msg: 'Successfully authenticated'
  }
]
```


## Respuestas e interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **¿Se puede demostrar qué cambió?** No: el perfilador estaba apagado (`was: 0`) y la bitácora no registra operaciones. **¿Quién se conectó a esa hora?** Sí se ve que una sesión con `appName=app-ventas-web` se conectó y se autenticó (`Successfully authenticated`), pero eso no prueba qué hizo.
2. **¿Por qué varias conexiones (conn8, conn9...)?** `mongosh` abre una conexión para monitorear el servidor y otra de trabajo. La que se autentica y ejecuta el comando es la de trabajo; en la otra aparece `Connection not authenticating`.

