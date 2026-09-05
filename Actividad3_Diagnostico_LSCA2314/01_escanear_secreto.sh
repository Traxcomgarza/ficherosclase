#!/bin/bash
# Actividad 3 - Fase 1: escaneo de secretos sobre evidencia/pasarela_pagos.py
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes

if [ ! -x "./bin/gitleaks" ]; then
  echo "ERROR: no existe ./bin/gitleaks. Corre primero ./bootstrap.sh" >&2
  exit 1
fi

echo "[Fase 1] Escaneando evidencia/ en busca de secretos con gitleaks..."
./bin/gitleaks detect --source evidencia --no-git --no-color -v > reportes/01_secreto.txt 2>&1
EXIT_CODE=$?

echo "  -> Reporte guardado en reportes/01_secreto.txt (codigo de salida $EXIT_CODE)"
if [ "$EXIT_CODE" -ne 0 ]; then
  echo "  -> Se encontro al menos un secreto. Este es tu insumo para el"
  echo "     Diagnostico de la plantilla de entrega."
else
  echo "  -> No se encontraron secretos. Revisa que evidencia/pasarela_pagos.py exista."
fi
