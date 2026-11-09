# Actividad 16 — Exportar y conservar la bitácora

- **Estudiante:** Jose Camilo Angulo Rivera
- **Actividad:** 16
- **Fecha de ejecución:** 2026-11-08 19:10:19 HMM


Comando de exportación (secreto sustituido por `<REDACTED>` antes de salir del servidor):

```bash
psql -U postgres -d comercial -At -c "SELECT replace(pg_read_file(pg_current_logfile()), 'Temporal_Practica_2026', '<REDACTED>')" > evidencias/bitacora-lab01.log
```
Hash SHA-256:

```text
9169687beb9f3a54a620b62cfb8b97ab5fc9432af857d8710f8a60cc3f8b5fb5 *evidencias/bitacora-lab01.log
```

Comprobación de que no quedó el secreto: `grep -c Temporal_Practica_2026` = 0

## Respuestas y interpretación (BORRADOR: verifica con tu salida y reescribe con tus palabras)

1. **¿SHA-256 impide modificar la bitácora?** No. Permite *demostrar* si el archivo cambió respecto al momento en que se calculó el hash.
2. **¿Dónde guardar el hash?** Fuera del servidor y bajo otra custodia (repositorio, sistema de bitácoras o tercero), para que quien altere el log no pueda alterar también el hash.
3. **Riesgos de conservar la bitácora solo en el servidor que la produce:** quien lo comprometa puede borrarla o alterarla; se pierde si el servidor falla o se reinstala; no hay separación entre quien opera y quien custodia.
4. **Retención propuesta:** escribe tu cifra y criterio (p. ej., 12 meses en línea y archivo posterior, según obligaciones legales, utilidad en investigaciones, costo y riesgo de conservar datos personales). No existe cifra única correcta.

