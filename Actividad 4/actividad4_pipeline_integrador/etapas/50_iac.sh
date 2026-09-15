#!/bin/bash
# Etapa 50 - Infraestructura como codigo (Tema 7)
# Umbral del gate: 0 hallazgos HIGH o CRITICAL. MEDIUM y LOW se reportan.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes

echo "== Etapa 50: infraestructura como codigo (trivy config) =="
./bin/trivy config plataforma_pedidos/infra > reportes/50_iac.txt 2>&1
./bin/trivy config plataforma_pedidos/infra --format json > reportes/50_iac.json 2>/dev/null

GRAVES=$(python3 -c "
import json
d=json.load(open('reportes/50_iac.json'))
n=0
for r in d.get('Results',[]):
    for m in r.get('Misconfigurations',[]):
        if m['Severity'] in ('HIGH','CRITICAL'): n+=1
print(n)
" 2>/dev/null || echo 99)

TODOS=$(python3 -c "
import json
d=json.load(open('reportes/50_iac.json'))
print(sum(len(r.get('Misconfigurations',[])) for r in d.get('Results',[])))
" 2>/dev/null || echo 0)

echo "  Hallazgos totales: $TODOS  |  HIGH/CRITICAL: $GRAVES"
if [ "$GRAVES" -eq 0 ]; then
  echo "0" > reportes/.50_exit; echo "  Resultado: PASA"; exit 0
else
  echo "1" > reportes/.50_exit; echo "  Resultado: FALLA (bloquea)"; exit 1
fi
