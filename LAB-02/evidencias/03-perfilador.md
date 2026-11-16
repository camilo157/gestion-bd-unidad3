# Actividad 3 — Activar el perfilador y registrar operaciones

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 3
- **Fecha de ejecución:** 2026-11-15 22:35:48 HMM
- **Nota:** en cada bloque de código, `bitacora()` es la función auxiliar de la sección 6.4 (definida al inicio de cada sesión).

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
printjson(db.setProfilingLevel(2)); printjson(db.getProfilingStatus())
```
Resultado:

```text
{
  was: 0,
  slowms: 100,
  sampleRate: 1,
  ok: 1
}
{
  was: 2,
  slowms: 100,
  sampleRate: 1,
  ok: 1
}
```

```js
// Sesión de la aplicación: mongosh "mongodb://app_ventas:<REDACTED>@127.0.0.1:27017/comercial?appName=app-ventas-web"
db.clientes.find({ ciudad: "Culiacán" }, { nombre: 1, ciudad: 1 }).toArray(); db.clientes.updateOne({ _id: 3 }, { $set: { rfc: "GAMA780912XYZ" } }); db.clientes.deleteOne({ _id: 2 });
```
Resultado:

```text
{ acknowledged: true, deletedCount: 1 }
```

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
printjson(db.system.profile.find(
  { ns: "comercial.clientes" },
  { op: 1, ns: 1, command: 1, user: 1, client: 1, appName: 1, ts: 1, millis: 1, nreturned: 1, docsExamined: 1, nModified: 1, ndeleted: 1 }
).sort({ ts: 1 }).toArray())
```
Resultado:

```text
[
  {
    op: 'query',
    ns: 'comercial.clientes',
    command: {
      find: 'clientes',
      filter: {
        ciudad: 'Culiacán'
      },
      projection: {
        nombre: 1,
        ciudad: 1
      },
      lsid: {
        id: UUID('58f07be5-181e-4b22-b4da-ebcda4e5387b')
      },
      '$db': 'comercial'
    },
    docsExamined: 5,
    nreturned: 3,
    millis: 0,
    ts: ISODate('2026-11-16T05:35:49.502Z'),
    client: '127.0.0.1',
    appName: 'app-ventas-web',
    user: 'app_ventas@comercial'
  },
  {
    op: 'update',
    ns: 'comercial.clientes',
    command: {
      q: {
        _id: 3
      },
      u: {
        '$set': {
          rfc: 'GAMA780912XYZ'
        }
      },
      multi: false,
      upsert: false
    },
    docsExamined: 1,
    nModified: 1,
    millis: 0,
    ts: ISODate('2026-11-16T05:35:49.507Z'),
    client: '127.0.0.1',
    appName: 'app-ventas-web',
    user: 'app_ventas@comercial'
  },
  {
    op: 'remove',
    ns: 'comercial.clientes',
    command: {
      q: {
        _id: 2
      },
      limit: 1
    },
    docsExamined: 1,
    ndeleted: 1,
    millis: 0,
    ts: ISODate('2026-11-16T05:35:49.511Z'),
    client: '127.0.0.1',
    appName: 'app-ventas-web',
    user: 'app_ventas@comercial'
  }
]
```


### 9.1 Interpretación de los documentos (generada a partir de system.profile)

| # | op | Usuario | Cliente | Aplicación | Momento (UTC) | Qué hizo | Documentos afectados |
|---|---|---|---|---|---|---|---|
| 1 | query | app_ventas@comercial | 127.0.0.1 | app-ventas-web | 2026-11-16T05:35:49.502Z | find {"ciudad":"Culiacán"} | examinados 5, devueltos 3 |
| 2 | update | app_ventas@comercial | 127.0.0.1 | app-ventas-web | 2026-11-16T05:35:49.507Z | update {"_id":3} {"$set":{"rfc":"GAMA780912XYZ"}} | modificados 1 |
| 3 | remove | app_ventas@comercial | 127.0.0.1 | app-ventas-web | 2026-11-16T05:35:49.511Z | delete {"_id":2} | eliminados 1 |


Se guardó una copia de la evidencia en `evidencias/system-profile-actividad3.json` antes de borrar `system.profile` (Actividad 4).


## Respuestas e interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **¿Se sabe el RFC anterior?** No. El documento del `update` solo contiene el `$set` con el valor nuevo; `system.profile` no guarda el valor previo.
2. **¿Se sabe qué datos tenía el documento eliminado?** No. El `remove` guarda solo el filtro (`{ _id: 2 }`) y que se eliminó 1 documento, no su contenido.
3. **Nivel 2 registró la consulta (a diferencia de `log_statement = 'mod'`):** *ventaja:* permite ver quién leyó qué datos. *Riesgo:* costo de desempeño, volumen y que los filtros pueden contener datos personales, con lo que `system.profile` se vuelve otro depósito de datos sensibles.
4. **¿Por qué `user` incluye `@comercial`?** Porque una identidad en MongoDB es usuario + base donde se definió; `app_ventas@comercial` es distinto de un `app_ventas` definido en otra base.

