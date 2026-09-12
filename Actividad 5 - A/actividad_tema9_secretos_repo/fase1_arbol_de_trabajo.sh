#!/bin/bash
# Tema 9 - Fase 1: escanear SOLO los archivos actuales (arbol de trabajo).
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes

if [ ! -x "./bin/gitleaks" ]; then
  echo "ERROR: no existe ./bin/gitleaks. Corre primero ./bootstrap.sh" >&2
  exit 1
fi

echo "[Fase 1] gitleaks dir -> escanea los archivos TAL COMO ESTAN HOY"
./bin/gitleaks dir repo_despliegue --no-color -v > reportes/fase1_arbol.txt 2>&1
EXIT_CODE=$?
echo "$EXIT_CODE" > reportes/.fase1_exit

echo "  -> Reporte: reportes/fase1_arbol.txt (codigo de salida $EXIT_CODE)"
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "  -> Resultado: LIMPIO. gitleaks no encontro nada en los archivos actuales."
  echo "     Antes de concluir que el repositorio esta seguro, corre la Fase 2."
else
  echo "  -> Resultado: se encontraron secretos en los archivos actuales."
fi
