-- Actividad 4 — Configurar la bitácora (recarga, no requiere reinicio)
ALTER SYSTEM SET log_connections = on;
ALTER SYSTEM SET log_disconnections = on;
ALTER SYSTEM SET log_line_prefix = '%m [%p] user=%u db=%d app=%a client=%h ';
ALTER SYSTEM SET log_statement = 'ddl';
SELECT pg_reload_conf();

-- Verificar en una consulta POSTERIOR (la recarga es asíncrona):
-- SELECT name, setting, source, sourcefile FROM pg_settings
-- WHERE name IN ('log_connections','log_line_prefix','log_statement');
