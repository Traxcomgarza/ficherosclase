#!/bin/bash
# Tema 10 - Fase 1: que tiene mal la imagen, antes de construirla.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes

if [ ! -x "./bin/trivy" ]; then
  echo "ERROR: no existe ./bin/trivy. Corre primero ./bootstrap.sh" >&2
  exit 1
fi

echo "[Fase 1] Analizando el Dockerfile (analisis estatico, no se construye nada)"
./bin/trivy config Dockerfile > reportes/fase1_dockerfile.txt 2>&1
./bin/trivy config Dockerfile --format json > reportes/fase1_dockerfile.json 2>/dev/null

TOTAL=$(python3 -c "
import json
d=json.load(open('reportes/fase1_dockerfile.json'))
print(sum(len(r.get('Misconfigurations',[])) for r in d.get('Results',[])))
" 2>/dev/null || echo 0)

echo "  -> Reporte: reportes/fase1_dockerfile.txt"
echo "  -> Hallazgos encontrados: $TOTAL"
echo "     Abre el reporte y fijate en la severidad de cada uno: uno es CRITICAL."
