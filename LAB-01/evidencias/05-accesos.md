# Actividad 5 — Accesos exitosos y fallidos

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 5
- **Fecha de ejecución:** 2026-11-08 19:09:37 HMM

```bash
psql "postgresql://app_ventas:<REDACTED>@127.0.0.1/comercial" -c "SELECT 1"
```
Resultado:

```text
psql: error: connection to server at "127.0.0.1", port 5432 failed: FATAL:  password authentication failed for user "app_ventas"
```

```bash
psql "postgresql://usuario_inexistente:<REDACTED>@127.0.0.1/comercial" -c "SELECT 1"
```
Resultado:

```text
psql: error: connection to server at "127.0.0.1", port 5432 failed: FATAL:  password authentication failed for user "usuario_inexistente"
```

```bash
psql "postgresql://app_ventas:<REDACTED>@127.0.0.1/comercial?application_name=app-ventas-web" -c "SELECT count(*) FROM clientes"
```
Resultado:

```text
 count 
-------
     5
(1 row)

```

```sql
SELECT linea FROM dba.bitacora WHERE linea LIKE '%client=127.0.0.1%' ORDER BY num;
```
Resultado:

```text
                                                                                                                             linea                                                                                                                              
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 2026-11-09 02:09:37.534 UTC [89] user=[unknown] db=[unknown] app=[unknown] client=127.0.0.1 LOG:  connection received: host=127.0.0.1 port=57104
 2026-11-09 02:09:37.542 UTC [89] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 FATAL:  password authentication failed for user "app_ventas"
 2026-11-09 02:09:37.542 UTC [89] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 DETAIL:  Connection matched file "/var/lib/postgresql/data/pg_hba.conf" line 119: "host    all             all             127.0.0.1/32            scram-sha-256"
 2026-11-09 02:09:37.789 UTC [96] user=[unknown] db=[unknown] app=[unknown] client=127.0.0.1 LOG:  connection received: host=127.0.0.1 port=57112
 2026-11-09 02:09:37.797 UTC [96] user=usuario_inexistente db=comercial app=[unknown] client=127.0.0.1 FATAL:  password authentication failed for user "usuario_inexistente"
 2026-11-09 02:09:37.797 UTC [96] user=usuario_inexistente db=comercial app=[unknown] client=127.0.0.1 DETAIL:  Role "usuario_inexistente" does not exist.
 2026-11-09 02:09:38.047 UTC [103] user=[unknown] db=[unknown] app=[unknown] client=127.0.0.1 LOG:  connection received: host=127.0.0.1 port=57116
 2026-11-09 02:09:38.055 UTC [103] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authenticated: identity="app_ventas" method=scram-sha-256 (/var/lib/postgresql/data/pg_hba.conf:119)
 2026-11-09 02:09:38.055 UTC [103] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 LOG:  connection authorized: user=app_ventas database=comercial application_name=app-ventas-web
 2026-11-09 02:09:38.057 UTC [103] user=app_ventas db=comercial app=app-ventas-web client=127.0.0.1 LOG:  disconnection: session time: 0:00:00.010 user=app_ventas database=comercial host=127.0.0.1 port=57116
(10 rows)

```


Conteo de intentos fallidos por usuario (pregunta 4):

```sql
SELECT substring(linea from 'user=(\S+)') AS usuario, count(*) AS fallos
FROM dba.bitacora
WHERE linea LIKE '%FATAL:  password authentication failed%'
GROUP BY 1 ORDER BY 2 DESC;
```
Resultado:

```text
       usuario       | fallos 
---------------------+--------
 app_ventas          |      1
 usuario_inexistente |      1
(2 rows)

```


### 11.1 Lectura campo por campo (ejemplo: línea FATAL)


| Campo | Valor | Significado |
|---|---|---|
| Fecha y hora | 2026-11-09 02:09:37.542 UTC | Momento exacto del rechazo, con milisegundos, en UTC |
| PID | 89 | Proceso de esa conexión; agrupa sus líneas (connection received, FATAL, DETAIL) |
| Usuario | app_ventas | Rol que el cliente presentó (no prueba quién es la persona) |
| Base de datos | comercial | Base solicitada |
| Aplicación | [unknown] | Aún no establecida: la autenticación falló antes de completar el inicio de sesión |
| Cliente | 127.0.0.1 | IP de origen (aquí, el propio equipo/contenedor) |
| Severidad | FATAL | La conexión se terminó |
| Mensaje | password authentication failed for user "app_ventas" | Motivo del rechazo |
| Regla aplicada | pg_hba.conf línea 119: `host all all 127.0.0.1/32 scram-sha-256` | Regla que coincidió (ver línea DETAIL) |

## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **¿Prueba que la aplicación de ventas intentó entrar?** No. Prueba que alguien presentó el nombre `app_ventas` desde esa IP; el nombre lo escribe el cliente y podría ser otra persona, script o atacante.
2. **Rol inexistente:** el log guarda `DETAIL: Role "..." does not exist`. Al cliente se le da el mismo mensaje genérico para no revelar si un usuario existe (evita enumeración de usuarios); el detalle queda solo para el administrador.
3. **`app=[unknown]` vs `app=app-ventas-web`:** `application_name` se aplica al completar el inicio de sesión; en el intento fallido la sesión no llegó a establecerse, y en la desconexión el valor ya estaba vigente.
4. **Fuerza bruta:** muchos `FATAL: password authentication failed` seguidos, del mismo usuario o desde la misma IP en poco tiempo (o muchos usuarios distintos desde una IP). La consulta de conteo por usuario está arriba.

