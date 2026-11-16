# Actividad 6 — Correlacionar un cambio de configuración con su autor

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 6
- **Fecha de ejecución:** 2026-11-15 22:35:56 HMM
- **Nota:** en cada bloque de código, `bitacora()` es la función auxiliar de la sección 6.4 (definida al inicio de cada sesión).

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
printjson(bitacora().filter(e => e.msg === "Profiler settings changed").map(e => ({ t: e.t, ctx: e.ctx, msg: e.msg, attr: e.attr })))
```
Resultado:

```text
[
  {
    t: {
      '$date': '2026-11-16T05:35:48.766+00:00'
    },
    ctx: 'conn34',
    msg: 'Profiler settings changed',
    attr: {
      from: {
        level: 0,
        slowms: 100,
        sampleRate: 1
      },
      to: {
        level: 2,
        slowms: 100,
        sampleRate: 1
      },
      db: 'comercial'
    }
  },
  {
    t: {
      '$date': '2026-11-16T05:35:52.456+00:00'
    },
    ctx: 'conn54',
    msg: 'Profiler settings changed',
    attr: {
      from: {
        level: 2,
        slowms: 100,
        sampleRate: 1
      },
      to: {
        level: 0,
        slowms: 100,
        sampleRate: 1
      },
      db: 'comercial'
    }
  },
  {
    t: {
      '$date': '2026-11-16T05:35:52.470+00:00'
    },
    ctx: 'conn54',
    msg: 'Profiler settings changed',
    attr: {
      from: {
        level: 0,
        slowms: 100,
        sampleRate: 1
      },
      to: {
        level: 1,
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
        }
      },
      db: 'comercial'
    }
  }
]
```


Autenticación de la misma conexión (ctx) que cambió la configuración por última vez (se toma automáticamente el ctx del último evento):

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
const cambios = bitacora().filter(e => e.msg === "Profiler settings changed");
const ult = cambios[cambios.length - 1];
print("ctx del último cambio de configuración: " + (ult ? ult.ctx : "no encontrado"));
if (ult) printjson(bitacora().filter(e => e.ctx === ult.ctx && e.msg === "Successfully authenticated").map(e => ({ t: e.t, ctx: e.ctx, user: e.attr.user, db: e.attr.db, client: e.attr.client })))
```
Resultado:

```text
ctx del último cambio de configuración: conn54
[
  {
    t: {
      '$date': '2026-11-16T05:35:52.328+00:00'
    },
    ctx: 'conn54',
    user: 'admin',
    db: 'admin',
    client: '127.0.0.1:38948'
  }
]
```


## Respuestas e interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **¿Qué usuario cambió la configuración del perfilador?** El que aparezca en la autenticación de la misma `ctx` (en este laboratorio, `admin`). Lo demuestran dos eventos: `Profiler settings changed` (con `from`/`to` y la `ctx`) y `Successfully authenticated` de esa misma `ctx`.
2. **Condición para que la correlación sea válida:** que ambos eventos pertenezcan a la misma ejecución del servidor y a la misma conexión; los números de conexión vuelven a empezar tras un reinicio, y `getLog` solo conserva los 1024 eventos más recientes (la autenticación podría haber salido de la memoria).
3. **¿Por qué importa que se registre el cambio de configuración del propio registro?** Porque quien controla el mecanismo puede apagarlo o reducirlo y crear un hueco de evidencia; el registro del cambio permite detectarlo y atribuirlo.

