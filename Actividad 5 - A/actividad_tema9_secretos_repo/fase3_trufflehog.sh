#!/bin/bash
# Tema 9 - Fase 3: el mismo historial, con OTRA herramienta.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes

if [ ! -x "./bin/trufflehog" ]; then
  echo "ERROR: no existe ./bin/trufflehog. Corre primero ./bootstrap.sh" >&2
  exit 1
fi

echo "[Fase 3] TruffleHog sobre el mismo historial"
echo "  (--no-verification: no intenta usar la credencial contra el servicio real)"
./bin/trufflehog git "file://$DIR/repo_despliegue" \
  --no-verification --no-update > reportes/fase3_trufflehog.txt 2>&1
EXIT_CODE=$?
echo "$EXIT_CODE" > reportes/.fase3_exit

HALLAZGOS=$(grep -c "Detector Type:" reportes/fase3_trufflehog.txt 2>/dev/null || echo 0)
echo "  -> Reporte: reportes/fase3_trufflehog.txt"
echo "  -> TruffleHog reporto $HALLAZGOS hallazgo(s) con su tipo de detector."
echo "     Comparalo con lo que reporto gitleaks en la Fase 2: no es lo mismo."
