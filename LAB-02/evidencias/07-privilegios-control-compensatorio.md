# Actividad 7 — Cambios de privilegios: el límite más importante

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 7
- **Fecha de ejecución:** 2026-11-15 22:35:58 HMM
- **Nota:** en cada bloque de código, `bitacora()` es la función auxiliar de la sección 6.4 (definida al inicio de cada sesión).


### Instantánea 1 (antes del cambio)

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
db.getSiblingDB("auditoria").instantaneas_privilegios.insertOne({ momento: new Date(), tomada_por: db.runCommand({ connectionStatus: 1 }).authInfo.authenticatedUsers, usuarios: db.getUsers().users.map(u => ({ user: u.user, db: u.db, roles: u.roles })) })
```
Resultado:

```text
{
  acknowledged: true,
  insertedId: ObjectId('6afa963e24229c578c409f8a')
}
```


### Cambio de privilegios con el perfilador en nivel 2

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
db.setProfilingLevel(2); db.grantRolesToUser("app_ventas", [{ role: "dbAdmin", db: "comercial" }])
```
Resultado:

```text
{ ok: 1 }
```


### Búsqueda de evidencia del cambio

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
printjson({
  perfilador: db.system.profile.countDocuments({ "command.grantRolesToUser": { $exists: true } }),
  bitacora: bitacora().filter(e => JSON.stringify(e).includes("grantRoles")).length
})
```
Resultado:

```text
{
  perfilador: 0,
  bitacora: 0
}
```


### Instantánea 2 (después del cambio) y comparación

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
db.getSiblingDB("auditoria").instantaneas_privilegios.insertOne({ momento: new Date(), tomada_por: db.runCommand({ connectionStatus: 1 }).authInfo.authenticatedUsers, usuarios: db.getUsers().users.map(u => ({ user: u.user, db: u.db, roles: u.roles })) })
```
Resultado:

```text
{
  acknowledged: true,
  insertedId: ObjectId('6afa9641f0beb43d81594d01')
}
```

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
printjson(db.getSiblingDB("auditoria").instantaneas_privilegios.find({}, { _id: 0 }).sort({ momento: 1 }).toArray())
```
Resultado:

```text
[
  {
    momento: ISODate('2026-11-16T05:35:58.941Z'),
    tomada_por: [
      {
        user: 'admin',
        db: 'admin'
      }
    ],
    usuarios: [
      {
        user: 'app_ventas',
        db: 'comercial',
        roles: [
          {
            role: 'readWrite',
            db: 'comercial'
          }
        ]
      }
    ]
  },
  {
    momento: ISODate('2026-11-16T05:36:01.191Z'),
    tomada_por: [
      {
        user: 'admin',
        db: 'admin'
      }
    ],
    usuarios: [
      {
        user: 'app_ventas',
        db: 'comercial',
        roles: [
          {
            role: 'dbAdmin',
            db: 'comercial'
          },
          {
            role: 'readWrite',
            db: 'comercial'
          }
        ]
      }
    ]
  }
]
```


### Revocar el rol y restablecer el filtro de la Actividad 4

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
db.revokeRolesFromUser("app_ventas", [{ role: "dbAdmin", db: "comercial" }]); printjson(db.setProfilingLevel(1, { filter: { op: { $in: ["insert", "update", "remove"] } } }))
```
Resultado:

```text
{
  was: 2,
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


| Pregunta | ¿La instantánea responde? |
|---|---|
| ¿Cambiaron los privilegios de app_ventas? | Sí |
| ¿Qué rol se agregó? | Sí |
| ¿Quién lo agregó? | **No** |
| ¿Cuándo exactamente? | **No**, solo que ocurrió entre dos instantáneas |

_Nota:_ la instantánea no sustituye a la auditoría nativa: es un control compensatorio que detecta el cambio pero no lo atribuye.


## Respuestas e interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **¿Por qué es uno de los eventos más importantes?** Porque otorgar privilegios amplía lo que alguien puede hacer (escalada de privilegios) y puede ser la preparación de un abuso o ataque; cambia toda la superficie de riesgo.
2. **Frecuencia de las instantáneas:** depende de la criticidad de los datos, la frecuencia de altas/cambios de usuarios, la ventana de detección tolerable, el costo de almacenamiento y los requisitos de cumplimiento (por ejemplo, cada hora o diario, y antes/después de cada cambio aprobado).
3. **¿Quién debería poder escribir en `auditoria.instantaneas_privilegios`?** Solo un rol o proceso de seguridad/auditoría independiente de quien administra usuarios; el DBA operativo no debería poder borrar o modificar esas instantáneas.
4. **Mensaje a Dirección (tres líneas):** «Con MongoDB Community podemos detectar que los privilegios de `app_ventas` cambiaron entre dos instantáneas, pero no podemos demostrar quién lo hizo ni a qué hora exacta. Es un control compensatorio, no una auditoría. Para atribuir el cambio se necesita auditoría nativa (Enterprise/Atlas) o controlar y registrar la administración de usuarios fuera del servidor.»

