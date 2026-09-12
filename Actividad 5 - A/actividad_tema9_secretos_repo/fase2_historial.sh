#!/bin/bash
# Tema 9 - Fase 2: escanear el HISTORIAL COMPLETO de Git.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes

if [ ! -x "./bin/gitleaks" ]; then
  echo "ERROR: no existe ./bin/gitleaks. Corre primero ./bootstrap.sh" >&2
  exit 1
fi

echo "[Fase 2] gitleaks git -> escanea TODOS los commits, no solo el ultimo"
./bin/gitleaks git repo_despliegue --no-color -v > reportes/fase2_historial.txt 2>&1
EXIT_CODE=$?
echo "$EXIT_CODE" > reportes/.fase2_exit

echo "  -> Reporte: reportes/fase2_historial.txt (codigo de salida $EXIT_CODE)"
if [ "$EXIT_CODE" -ne 0 ]; then
  echo "  -> Resultado: SE ENCONTRO un secreto que ya no esta en los archivos"
  echo "     actuales, pero sigue vivo dentro del historial de commits."
  echo "     Abre el reporte y anota en que commit quedo."
else
  echo "  -> Resultado: sin hallazgos en el historial."
fi
