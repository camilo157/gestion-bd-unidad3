-- PARTE C (opcional) — Requiere el paquete postgresql-16-pgaudit instalado (ver Anexo A.3 de la guía)
ALTER SYSTEM SET shared_preload_libraries = 'pgaudit';
-- >>> REINICIAR el servicio <<<
CREATE EXTENSION pgaudit;
SELECT extname, extversion FROM pg_extension WHERE extname = 'pgaudit';

CREATE ROLE auditor_datos NOLOGIN;
GRANT SELECT (rfc, telefono), UPDATE (rfc, telefono) ON clientes TO auditor_datos;
ALTER SYSTEM SET pgaudit.log = 'role, ddl';
ALTER SYSTEM SET pgaudit.role = 'auditor_datos';
ALTER SYSTEM SET pgaudit.log_relation = on;
SELECT pg_reload_conf();
