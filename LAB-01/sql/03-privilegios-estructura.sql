-- Actividad 6 — Cambios de privilegios y de estructura (con log_statement = 'ddl')
REVOKE UPDATE ON clientes FROM soporte_ana;
GRANT UPDATE ON clientes TO app_ventas;
ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20);

-- 12.1 La bitácora puede filtrar secretos (contraseña de PRÁCTICA, rol desechable)
CREATE ROLE rol_temporal LOGIN PASSWORD 'Temporal_Practica_2026';
DROP ROLE rol_temporal;

-- Consulta de verificación (en una consulta posterior):
-- SELECT linea FROM dba.bitacora WHERE linea LIKE '%statement:%' ORDER BY num;
