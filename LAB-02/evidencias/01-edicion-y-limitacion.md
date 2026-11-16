# Actividad 1 — Lo que no existe en esta edición

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 1
- **Fecha de ejecución:** 2026-11-15 22:35:43 HMM
- **Nota:** en cada bloque de código, `bitacora()` es la función auxiliar de la sección 6.4 (definida al inicio de cada sesión).


Despliegue: contenedor Docker `dba-u3-mongo` con la imagen oficial `mongo:7`, arrancado con `--auth` (Anexo A.2).

```js
// Sesión del DBA: mongosh "mongodb://admin:<REDACTED>@127.0.0.1:27017/comercial?authSource=admin"
printjson({
  version: db.version(),
  modules: db.adminCommand({ buildInfo: 1 }).modules,
  parsed: db.serverCmdLineOpts().parsed
})
```
Resultado:

```text
{
  version: '7.0.45',
  modules: [],
  parsed: {
    net: {
      bindIp: '*'
    },
    security: {
      authorization: 'enabled'
    }
  }
}
```


Últimas líneas de la salida estándar del contenedor (destino de la bitácora, pues no hay `systemLog` configurado):

```bash
docker logs dba-u3-mongo --tail 2
```
```text
{"t":{"$date":"2026-11-16T05:35:44.814+00:00"},"s":"I",  "c":"NETWORK",  "id":22944,   "ctx":"conn16","msg":"Connection ended","attr":{"remote":"127.0.0.1:38582","isLoadBalanced":false,"uuid":{"uuid":{"$uuid":"83e6348a-29dd-487b-8658-6766185de2b7"}},"connectionId":16,"connectionCount":1}}
{"t":{"$date":"2026-11-16T05:35:44.814+00:00"},"s":"I",  "c":"NETWORK",  "id":22944,   "ctx":"conn14","msg":"Connection ended","attr":{"remote":"127.0.0.1:38562","isLoadBalanced":false,"uuid":{"uuid":{"$uuid":"8ee095a8-3b36-4675-9c20-f6c229eec6d3"}},"connectionId":14,"connectionCount":0}}
```


## Respuestas e interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **Edición:** MongoDB Community. La evidencia es que `modules` está vacío (`[]`); en Enterprise incluiría `"enterprise"`. La auditoría nativa (`--auditDestination`) no está disponible en esta edición (REF-U3-04).
2. **Destino de la bitácora:** la salida estándar del proceso (se lee con `docker logs`). Lo sé porque `serverCmdLineOpts().parsed` no muestra ninguna sección `systemLog` con `destination: file`.
3. **Cuatro categorías de la auditoría nativa:** cambios de esquema (DDL); eventos de conjuntos de réplicas y clústeres fragmentados; autenticación y autorización; operaciones CRUD (requiere `auditAuthorizationSuccess: true`).
4. **Antes de licenciar Enterprise o migrar a Atlas** habría que evaluar: costo de licencia o de clústeres M10+, esfuerzo de migración, qué eventos se necesitan realmente, volumen y almacenamiento de la auditoría, custodia de los registros, y si un control compensatorio basta para el riesgo.

