# Entorno y reglas de autenticación (secciones 6.3 y 6.4)

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** Preparación
- **Fecha de ejecución:** 2026-11-08 19:09:17 HMM


Despliegue: contenedor Docker `dba-u3-pg` con la imagen oficial `postgres:16`.

```sql
SELECT version();
SHOW data_directory;
SHOW config_file;
SHOW hba_file;
SELECT line_number, type, database, user_name, address, auth_method FROM pg_hba_file_rules WHERE database = '{all}';
```
Resultado:

```text
                                                       version                                                        
----------------------------------------------------------------------------------------------------------------------
 PostgreSQL 16.15 (Debian 16.15-1.pgdg13+2) on x86_64-pc-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit
(1 row)

      data_directory      
--------------------------
 /var/lib/postgresql/data
(1 row)

               config_file                
------------------------------------------
 /var/lib/postgresql/data/postgresql.conf
(1 row)

               hba_file               
--------------------------------------
 /var/lib/postgresql/data/pg_hba.conf
(1 row)

 line_number | type  | database | user_name |  address  |  auth_method  
-------------+-------+----------+-----------+-----------+---------------
         117 | local | {all}    | {all}     |           | trust
         119 | host  | {all}    | {all}     | 127.0.0.1 | trust
         121 | host  | {all}    | {all}     | ::1       | trust
         128 | host  | {all}    | {all}     | all       | scram-sha-256
(4 rows)

```


Cambio de trust a scram-sha-256 en las reglas host de 127.0.0.1 y ::1 (Anexo A.2):

```bash
docker exec dba-u3-pg bash -c "sed -i -E 's/^(host +all +all +(127\.0\.0\.1\/32|::1\/128) +)trust/\1scram-sha-256/' /var/lib/postgresql/data/pg_hba.conf"
```
```sql
SELECT pg_reload_conf();
```
Resultado:

```text
 pg_reload_conf 
----------------
 t
(1 row)

```

```sql
SELECT line_number, type, database, user_name, address, auth_method FROM pg_hba_file_rules WHERE database = '{all}';
```
Resultado:

```text
 line_number | type  | database | user_name |  address  |  auth_method  
-------------+-------+----------+-----------+-----------+---------------
         117 | local | {all}    | {all}     |           | trust
         119 | host  | {all}    | {all}     | 127.0.0.1 | scram-sha-256
         121 | host  | {all}    | {all}     | ::1       | scram-sha-256
         128 | host  | {all}    | {all}     | all       | scram-sha-256
(4 rows)

```


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

**¿Por qué una regla `trust` afecta lo que la bitácora puede demostrar sobre la identidad?**
Con `trust` el servidor acepta el nombre de usuario que declara el cliente sin verificar nada. La bitácora registraría un `user=` que cualquiera pudo escribir, y nunca habría accesos fallidos. Es el mismo principio de endurecimiento de la Unidad II: sin autenticación fuerte (scram-sha-256) el usuario registrado no prueba la identidad real.

