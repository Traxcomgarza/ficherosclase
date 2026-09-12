#!/bin/bash
# Tema 10 - Fase 4: que vulnerabilidades entrarian DENTRO de la imagen.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes

if [ ! -f "venv/bin/activate" ]; then
  echo "ERROR: no existe el entorno virtual. Corre primero ./bootstrap.sh" >&2
  exit 1
fi
# shellcheck disable=SC1091
source venv/bin/activate

echo "[Fase 4] Revisando las dependencias que la imagen va a instalar"
pip-audit -r servicio_catalogo/requirements.txt > reportes/fase4_dependencias.txt 2>&1
EXIT_CODE=$?
echo "$EXIT_CODE" > reportes/.fase4_exit

echo "  -> Reporte: reportes/fase4_dependencias.txt (codigo de salida $EXIT_CODE)"
if [ "$EXIT_CODE" -ne 0 ]; then
  echo "  -> Se encontraron vulnerabilidades conocidas. Un Dockerfile perfecto"
  echo "     no sirve de nada si adentro instalas librerias vulnerables."
else
  echo "  -> Sin vulnerabilidades conocidas."
fi
