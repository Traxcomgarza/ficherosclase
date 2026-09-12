#!/bin/bash
# Tema 10 - Fase 2: corrige el Dockerfile y comprueba que los hallazgos bajan.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes

if [ ! -x "./bin/trivy" ]; then
  echo "ERROR: no existe ./bin/trivy. Corre primero ./bootstrap.sh" >&2
  exit 1
fi

echo "[Fase 2] Analizando Dockerfile.endurecido (el que completas tu)"
./bin/trivy config Dockerfile.endurecido > reportes/fase2_endurecido.txt 2>&1
./bin/trivy config Dockerfile.endurecido --format json > reportes/fase2_endurecido.json 2>/dev/null

TOTAL=$(python3 -c "
import json
d=json.load(open('reportes/fase2_endurecido.json'))
print(sum(len(r.get('Misconfigurations',[])) for r in d.get('Results',[])))
" 2>/dev/null || echo 0)

echo "$TOTAL" > reportes/.fase2_total
echo "  -> Reporte: reportes/fase2_endurecido.txt"
echo "  -> Hallazgos que quedan: $TOTAL"

if [ "$TOTAL" -eq 0 ]; then
  echo "  -> Listo: corregiste los 5 hallazgos. Esa es la version de la imagen"
  echo "     que si deberia construirse."
else
  echo "  -> Todavia faltan $TOTAL. Abre Dockerfile.endurecido, resuelve los TODO"
  echo "     que siguen pendientes y vuelve a correr esta fase."
fi
