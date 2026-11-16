# Actividad 4 — Reducir el volumen con un filtro

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 4
- **Fecha de ejecución:** 2026-11-15 22:35:51 HMM
- **Nota:** en cada bloque de código, `bitacora()` es la función auxiliar de la sección 6.4 (definida al inicio de cada sesión).

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
db.setProfilingLevel(0); db.system.profile.drop(); printjson(db.setProfilingLevel(1, { filter: { op: { $in: ["insert", "update", "remove"] } } })); printjson(db.getProfilingStatus())
```
Resultado:

```text
{
  was: 0,
  slowms: 100,
  sampleRate: 1,
  note: 'When a filter expression is set, slowms and sampleRate are not used for profiling and slow-query log lines.',
  ok: 1
}
{
  was: 1,
  slowms: 100,
  sampleRate: 1,
  filter: {
    op: {
      '$in': [
        'insert',
        'remove',
        'update'
      ]
    }
  },
  note: 'When a filter expression is set, slowms and sampleRate are not used for profiling and slow-query log lines.',
  ok: 1
}
```

```js
// Sesión de la aplicación: mongosh "mongodb://app_ventas:<REDACTED>@127.0.0.1:27017/comercial?appName=app-ventas-web"
db.clientes.find({ _id: 1 }).toArray(); db.clientes.updateOne({ _id: 1 }, { $set: { telefono: "6670000000" } })
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
printjson(db.system.profile.find({}, { op: 1, ns: 1, user: 1, appName: 1, "command.q": 1, "command.u": 1, ts: 1 }).toArray())
```
Resultado:

```text
[
  {
    op: 'update',
    ns: 'comercial.clientes',
    command: {
      q: {
        _id: 1
      },
      u: {
        '$set': {
          telefono: '6670000000'
        }
      }
    },
    ts: ISODate('2026-11-16T05:35:53.193Z'),
    appName: 'app-ventas-web',
    user: 'app_ventas@comercial'
  }
]
```


## Respuestas e interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **¿Qué se perdió y qué se ganó?** Se perdió la evidencia de lecturas (las consultas `query`) y de otros tipos de operación; además, con un filtro dejan de usarse `slowms` y `sampleRate`. Se ganó menos volumen, menor costo de rendimiento, menos datos personales expuestos en `system.profile` y más tiempo de vida de la evidencia en una colección de solo 1 MB.
2. **Filtro solo para la colección `clientes`:** `{ ns: "comercial.clientes", op: { $in: ["insert", "update", "remove"] } }`.

