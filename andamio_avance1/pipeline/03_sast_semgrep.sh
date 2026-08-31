#!/bin/bash
# Etapa 3 de 5 - SAST con semgrep (reglas propias, sin depender de internet)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source venv/bin/activate
mkdir -p reportes
export SEMGREP_SEND_METRICS=off

echo "[Etapa 3/5] SAST (semgrep) sobre repo_reto/app.py ..."

# =============================================================================
# TODO (Etapa 3): escribe aqui abajo el comando de semgrep.
#
# Debe cumplir 4 cosas:
#   - Usar el archivo de reglas propio: reglas_semgrep_locales.yml (ya viene
#     armado, no lo modifiques).
#   - Analizar repo_reto/app.py.
#   - Usar --disable-version-check (para no intentar conectarse a internet).
#   - Usar --error (para que el codigo de salida sea distinto de cero si hay
#     hallazgos bloqueantes).
#   - Guardar la salida (redirigida) en reportes/fase3_sast_semgrep.txt.
#
# Documentacion: semgrep --help
#
semgrep --config reglas_semgrep_locales.yml repo_reto/app.py --disable-version-check --error > reportes/fase3_sast_semgrep.txt 2>&1
# =============================================================================

EXIT_CODE=$?
echo "$EXIT_CODE" > reportes/.fase3_exit
if [ "$EXIT_CODE" -ne 0 ]; then
  echo "  -> semgrep encontro hallazgos bloqueantes (codigo de salida $EXIT_CODE)."
else
  echo "  -> semgrep no encontro hallazgos bloqueantes (codigo de salida $EXIT_CODE)."
fi
exit "$EXIT_CODE"
