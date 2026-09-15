#!/bin/bash
# Etapa 10 - Secretos en el codigo actual (Temas 1 y 2)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes

echo "== Etapa 10: secretos en el arbol de trabajo (gitleaks dir) =="
./bin/gitleaks dir plataforma_pedidos --no-color -v > reportes/10_secretos_arbol.txt 2>&1
CODIGO=$?
HALLAZGOS=$(grep -c "RuleID:" reportes/10_secretos_arbol.txt 2>/dev/null || echo 0)

echo "$CODIGO" > reportes/.10_exit
echo "  Secretos encontrados en el codigo: $HALLAZGOS"
[ "$CODIGO" -eq 0 ] && echo "  Resultado: PASA" || echo "  Resultado: FALLA (bloquea)"
exit "$CODIGO"
