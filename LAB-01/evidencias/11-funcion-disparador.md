# Actividad 11 — Función y disparador

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 11
- **Fecha de ejecución:** 2026-11-08 19:10:13 HMM

Script `sql/05-funcion-disparador.sql` (psql -a: cada sentencia seguida de su resultado):

```text
-- Actividad 11 — Función (SECURITY DEFINER, search_path fijo) y disparador
CREATE OR REPLACE FUNCTION auditoria.registrar_cambio_cliente()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria.cambios_clientes (operacion, id_cliente, valores_despues)
        VALUES (TG_OP, NEW.id, to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria.cambios_clientes (operacion, id_cliente, valores_antes, valores_despues)
        VALUES (TG_OP, NEW.id, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria.cambios_clientes (operacion, id_cliente, valores_antes)
        VALUES (TG_OP, OLD.id, to_jsonb(OLD));
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;
CREATE FUNCTION
REVOKE ALL ON FUNCTION auditoria.registrar_cambio_cliente() FROM PUBLIC;
REVOKE
CREATE TRIGGER trg_auditoria_clientes
AFTER INSERT OR UPDATE OR DELETE ON clientes
FOR EACH ROW EXECUTE FUNCTION auditoria.registrar_cambio_cliente();
CREATE TRIGGER
SELECT tgname, tgenabled, tgrelid::regclass FROM pg_trigger WHERE NOT tgisinternal;
         tgname         | tgenabled | tgrelid  
------------------------+-----------+----------
 trg_auditoria_clientes | O         | clientes
(1 row)

```

```sql
SELECT linea FROM dba.bitacora WHERE linea ~ 'statement: (CREATE|REVOKE)' ORDER BY num DESC LIMIT 8;
```
Resultado:

```text
                                                                                     linea                                                                                      
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 2026-11-09 02:10:13.348 UTC [244] user=postgres db=comercial app=psql client=[local] LOG:  statement: CREATE TRIGGER trg_auditoria_clientes
 2026-11-09 02:10:13.347 UTC [244] user=postgres db=comercial app=psql client=[local] LOG:  statement: REVOKE ALL ON FUNCTION auditoria.registrar_cambio_cliente() FROM PUBLIC;
 2026-11-09 02:10:13.345 UTC [244] user=postgres db=comercial app=psql client=[local] LOG:  statement: CREATE OR REPLACE FUNCTION auditoria.registrar_cambio_cliente()
 2026-11-09 02:10:13.044 UTC [237] user=postgres db=comercial app=psql client=[local] LOG:  statement: CREATE TABLE auditoria.cambios_clientes (
 2026-11-09 02:10:13.043 UTC [237] user=postgres db=comercial app=psql client=[local] LOG:  statement: REVOKE ALL ON SCHEMA auditoria FROM PUBLIC;
 2026-11-09 02:10:13.041 UTC [237] user=postgres db=comercial app=psql client=[local] LOG:  statement: CREATE SCHEMA auditoria;
 2026-11-09 02:09:40.003 UTC [124] user=postgres db=comercial app=psql client=[local] LOG:  statement: CREATE ROLE rol_temporal LOGIN PASSWORD 'Temporal_Practica_2026';
 2026-11-09 02:09:39.999 UTC [124] user=postgres db=comercial app=psql client=[local] LOG:  statement: REVOKE UPDATE ON clientes FROM soporte_ana;
(8 rows)

```


## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **¿Por qué `REVOKE ALL ON FUNCTION ... FROM PUBLIC`?** Mínimo privilegio: nadie debe poder invocar/usar la función de auditoría; el disparador funciona igual para `app_ventas` porque no se exige EXECUTE al dispararse.
2. **Hipótesis sin SECURITY DEFINER:** la función correría con privilegios de `app_ventas`, que no puede escribir en el esquema `auditoria`; el UPDATE fallaría con `permission denied`.
3. **¿Quedó registrada la creación?** Sí, porque `log_statement = mod` incluye las sentencias `ddl` (CREATE SCHEMA/TABLE/FUNCTION/TRIGGER).

