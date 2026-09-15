#!/bin/bash
# Etapa 30 - Dependencias de terceros / SCA (Tema 5)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes
# shellcheck disable=SC1091
source venv/bin/activate

echo "== Etapa 30: dependencias vulnerables (pip-audit) =="
pip-audit -r plataforma_pedidos/requirements.txt > reportes/30_sca.txt 2>&1
CODIGO=$?

echo "$CODIGO" > reportes/.30_exit
head -1 reportes/30_sca.txt | sed 's/^/  /'
[ "$CODIGO" -eq 0 ] && echo "  Resultado: PASA" || echo "  Resultado: FALLA (bloquea)"
exit "$CODIGO"
