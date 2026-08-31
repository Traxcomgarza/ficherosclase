#!/bin/bash
# Etapa 5 de 5 - Dependencias (pip-audit)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source venv/bin/activate
mkdir -p reportes

echo "[Etapa 5/5] Dependencias (pip-audit) sobre repo_reto/requirements.txt ..."

# =============================================================================
# TODO (Etapa 5): escribe aqui abajo el comando de pip-audit.
#
# Debe cumplir 2 cosas:
#   - Leer el archivo repo_reto/requirements.txt como fuente de dependencias.
#   - Guardar la salida (redirigida) en reportes/fase5_sca.txt.
#
# Documentacion: pip-audit --help
#
pip-audit -r repo_reto/requirements.txt > reportes/fase5_sca.txt 2>&1
# =============================================================================

EXIT_CODE=$?
echo "$EXIT_CODE" > reportes/.fase5_exit
if [ "$EXIT_CODE" -ne 0 ]; then
  echo "  -> pip-audit encontro vulnerabilidades (codigo de salida $EXIT_CODE)."
else
  echo "  -> pip-audit no encontro vulnerabilidades (codigo de salida $EXIT_CODE)."
fi
exit "$EXIT_CODE"
