-- Actividad 2 — Colector de bitácora propio del servidor y vista dba.bitacora
ALTER SYSTEM SET logging_collector = on;
SELECT name, setting, pending_restart FROM pg_settings WHERE name = 'logging_collector';

-- >>> REINICIAR EL SERVICIO AQUÍ (docker restart dba-u3-pg) y abrir sesión nueva <<<

SELECT name, setting, source FROM pg_settings WHERE name = 'logging_collector';
SELECT pg_current_logfile();

SELECT linea
FROM regexp_split_to_table(pg_read_file(pg_current_logfile()), E'\n') AS linea;

CREATE SCHEMA dba;
REVOKE ALL ON SCHEMA dba FROM PUBLIC;

CREATE VIEW dba.bitacora AS
SELECT t.n AS num, t.linea
FROM regexp_split_to_table(pg_read_file(pg_current_logfile()), E'\n')
     WITH ORDINALITY AS t(linea, n)
WHERE t.linea <> '';

SELECT num, linea FROM dba.bitacora ORDER BY num DESC LIMIT 10;
SELECT linea FROM dba.bitacora WHERE linea ILIKE '%update%';
SELECT linea FROM dba.bitacora WHERE linea ~ '(FATAL|ERROR)';
SELECT * FROM pg_ls_logdir();
