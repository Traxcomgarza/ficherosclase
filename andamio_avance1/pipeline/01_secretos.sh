#!/bin/bash
# Etapa 1 de 5 - Secretos (gitleaks)
# La estructura del pipeline ya esta armada (rutas, reporte, codigo de
# salida). Tu trabajo es escribir el comando de gitleaks correcto.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
mkdir -p reportes

echo "[Etapa 1/5] Secretos (gitleaks) sobre repo_reto/ ..."

# =============================================================================
# TODO (Etapa 1): escribe aqui abajo el comando de gitleaks.
#
# Debe cumplir 3 cosas:
#   - Escanear la carpeta repo_reto/ (todo el contenido, no un archivo suelto).
#   - repo_reto/ NO es un repositorio git real: necesitas la bandera correcta
#     para que gitleaks no intente leer historial de git.
#   - Guardar la salida (redirigida) en reportes/fase1_secretos.txt.
#
# Documentacion: ./bin/gitleaks detect --help
#
./bin/gitleaks detect --source repo_reto --no-git -v > reportes/fase1_secretos.txt 2>&1
# =============================================================================

EXIT_CODE=$?
echo "$EXIT_CODE" > reportes/.fase1_exit
if [ "$EXIT_CODE" -ne 0 ]; then
  echo "  -> gitleaks encontro secretos (codigo de salida $EXIT_CODE)."
else
  echo "  -> gitleaks no encontro secretos (codigo de salida $EXIT_CODE)."
fi
exit "$EXIT_CODE"
