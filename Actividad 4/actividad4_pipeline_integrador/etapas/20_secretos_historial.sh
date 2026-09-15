#!/bin/bash
# Etapa 20 - Secretos en el historial de Git (Tema 9)
# Esta etapa NUNCA bloquea: un secreto ya publicado no se puede "des-publicar".
# Lo que exige es constancia y rotacion documentada.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes

echo "== Etapa 20: secretos en el HISTORIAL (gitleaks git + TruffleHog) =="
echo "   Requiere historial completo. En GitHub Actions: fetch-depth: 0"

./bin/gitleaks git plataforma_pedidos --no-color -v > reportes/20_historial_gitleaks.txt 2>&1
CODIGO_GL=$?
./bin/trufflehog git "file://$DIR/plataforma_pedidos" --no-verification --no-update \
  > reportes/20_historial_trufflehog.txt 2>&1

GL=$(grep -c "RuleID:" reportes/20_historial_gitleaks.txt 2>/dev/null || echo 0)
TH=$(grep -c "Detector Type:" reportes/20_historial_trufflehog.txt 2>/dev/null || echo 0)

echo "$GL" > reportes/.20_hallazgos
echo "  gitleaks reporto:   $GL hallazgo(s) en el historial"
echo "  TruffleHog reporto: $TH hallazgo(s) en el historial"

if [ "$CODIGO_GL" -ne 0 ]; then
  echo "  Resultado: ADVERTENCIA (no bloquea, pero exige rotacion documentada)"
else
  echo "  Resultado: PASA"
fi
echo "0" > reportes/.20_exit
exit 0
