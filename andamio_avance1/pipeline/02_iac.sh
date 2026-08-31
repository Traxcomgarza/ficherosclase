#!/bin/bash
# Etapa 2 de 5 - Infraestructura como codigo (checkov)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source venv/bin/activate
mkdir -p reportes

echo "[Etapa 2/5] Infraestructura (checkov) sobre repo_reto/infraestructura ..."
echo "(El .tf se analiza de forma estatica, nunca se despliega.)"

# =============================================================================
# TODO (Etapa 2): escribe aqui abajo el comando de checkov.
#
# Debe cumplir 2 cosas:
#   - Analizar el directorio repo_reto/infraestructura (no un archivo suelto).
#   - Usar el modo de salida compacto.
#   - Guardar la salida (redirigida) en reportes/fase2_infraestructura.txt.
#
# Documentacion: checkov --help
#
checkov -d repo_reto/infraestructura --compact > reportes/fase2_infraestructura.txt 2>&1
# =============================================================================

EXIT_CODE=$?
echo "$EXIT_CODE" > reportes/.fase2_exit
if [ "$EXIT_CODE" -ne 0 ]; then
  echo "  -> checkov encontro configuraciones inseguras (codigo de salida $EXIT_CODE)."
else
  echo "  -> checkov no encontro fallas (codigo de salida $EXIT_CODE)."
fi
exit "$EXIT_CODE"
