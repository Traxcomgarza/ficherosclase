#!/bin/bash
# Etapa 4 de 5 - SAST con bandit (especifico de Python)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source venv/bin/activate
mkdir -p reportes

echo "[Etapa 4/5] SAST (bandit) sobre repo_reto/app.py ..."

# =============================================================================
# TODO (Etapa 4): escribe aqui abajo el comando de bandit.
#
# Debe cumplir 2 cosas:
#   - Analizar repo_reto/app.py.
#   - Guardar la salida (redirigida) en reportes/fase4_sast_bandit.txt.
#
# Documentacion: bandit --help
#
bandit repo_reto/app.py > reportes/fase4_sast_bandit.txt 2>&1
# =============================================================================

EXIT_CODE=$?
echo "$EXIT_CODE" > reportes/.fase4_exit
if [ "$EXIT_CODE" -ne 0 ]; then
  echo "  -> bandit encontro hallazgos (codigo de salida $EXIT_CODE)."
else
  echo "  -> bandit no encontro hallazgos (codigo de salida $EXIT_CODE)."
fi
exit "$EXIT_CODE"
