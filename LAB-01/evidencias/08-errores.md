# Actividad 8 — Errores y operaciones rechazadas

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 8
- **Fecha de ejecución:** 2026-11-08 19:09:47 HMM

```bash
psql "postgresql://soporte_ana:<REDACTED>@127.0.0.1/comercial" -c "DELETE FROM clientes WHERE id = 5"
```
Resultado:

```text
ERROR:  permission denied for table clientes
```

```sql
DROP ROLE soporte_ana;
```
Resultado:

```text
ERROR:  role "soporte_ana" cannot be dropped because some objects depend on it
DETAIL:  privileges for table clientes
```

```sql
SELECT linea FROM dba.bitacora
WHERE linea ~ '(ERROR|STATEMENT|DETAIL):  (permission|privileges|role|DELETE|DROP)'
ORDER BY num;
```
Resultado:

```text
                                                                                linea                                                                                
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
 2026-11-09 02:09:48.201 UTC [173] user=soporte_ana db=comercial app=psql client=127.0.0.1 ERROR:  permission denied for table clientes
 2026-11-09 02:09:48.201 UTC [173] user=soporte_ana db=comercial app=psql client=127.0.0.1 STATEMENT:  DELETE FROM clientes WHERE id = 5
 2026-11-09 02:09:48.482 UTC [180] user=postgres db=comercial app=psql client=[local] ERROR:  role "soporte_ana" cannot be dropped because some objects depend on it
 2026-11-09 02:09:48.482 UTC [180] user=postgres db=comercial app=psql client=[local] DETAIL:  privileges for table clientes
 2026-11-09 02:09:48.482 UTC [180] user=postgres db=comercial app=psql client=[local] STATEMENT:  DROP ROLE soporte_ana;
(5 rows)

```


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **¿Hubo daño?** No, el servidor rechazó el DELETE. Aun así debe auditarse: es un intento de operación no autorizada (cuenta mal usada, comprometida o abuso).
2. **Autorización vs. autenticación:** la autenticación (Actividad 5) falla al probar *quién eres* y no se crea sesión; la autorización falla cuando ya estás autenticado pero *no tienes permiso* para esa operación.
3. **`DROP ROLE` fallido:** antes de dar de baja a un usuario hay que retirar sus privilegios y reasignar/eliminar sus objetos (`REVOKE`, `REASSIGN OWNED`, `DROP OWNED`).

