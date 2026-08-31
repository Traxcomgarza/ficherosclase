#!/bin/bash
# Verificacion del Avance 1 del Reto - LSCA2314
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

TOTAL=0
OK=0

check() {
  TOTAL=$((TOTAL+1))
  if eval "$2"; then
    echo "  [OK] $1"
    OK=$((OK+1))
  else
    echo "  [ ] $1"
  fi
}

echo "=================================================="
echo " Verificacion - Avance 1 del Reto"
echo "=================================================="

check "Entorno virtual creado (venv/)" "[ -d venv ]"
check "gitleaks descargado (bin/gitleaks)" "[ -x bin/gitleaks ]"

check "Etapa 1 completada (sin el 'exit 99' de ejemplo)" "! grep -q 'exit 99' pipeline/01_secretos.sh"
check "Etapa 2 completada (sin el 'exit 99' de ejemplo)" "! grep -q 'exit 99' pipeline/02_iac.sh"
check "Etapa 3 completada (sin el 'exit 99' de ejemplo)" "! grep -q 'exit 99' pipeline/03_sast_semgrep.sh"
check "Etapa 4 completada (sin el 'exit 99' de ejemplo)" "! grep -q 'exit 99' pipeline/04_sast_bandit.sh"
check "Etapa 5 completada (sin el 'exit 99' de ejemplo)" "! grep -q 'exit 99' pipeline/05_sca.sh"
check "Logica de bloqueo del orquestador completada" "! grep -q 'exit 99' orquestador.sh"

echo ""
echo "Corriendo el pipeline completo para verificar el comportamiento real..."
bash orquestador.sh > reportes/.orquestador_salida.txt 2>&1
ORQ_EXIT=$?

check "Etapa 1 (gitleaks) produjo hallazgos reales" "grep -q 'leaks found' reportes/fase1_secretos.txt 2>/dev/null"
check "Etapa 2 (checkov) produjo hallazgos reales" "grep -q 'Failed checks' reportes/fase2_infraestructura.txt 2>/dev/null"
check "Etapa 3 (semgrep) produjo hallazgos reales" "grep -qi 'findings' reportes/fase3_sast_semgrep.txt 2>/dev/null"
check "Etapa 4 (bandit) produjo hallazgos reales" "grep -qi 'Issue:' reportes/fase4_sast_bandit.txt 2>/dev/null"
check "Etapa 5 (pip-audit) produjo hallazgos reales" "grep -q 'known vulnerabilities' reportes/fase5_sca.txt 2>/dev/null"

check "El pipeline completo bloquea correctamente (DESPLIEGUE BLOQUEADO, exit 1)" \
  "grep -q 'DESPLIEGUE BLOQUEADO' reportes/.orquestador_salida.txt && [ '$ORQ_EXIT' -eq 1 ]"

check "guia_hallazgos.csv sin placeholders pendientes" "! grep -q '\[COMPLETAR\]' guia_hallazgos.csv 2>/dev/null"

echo ""
echo "=================================================="
echo " Resultado: $OK / $TOTAL"
echo "=================================================="

if [ "$OK" -eq "$TOTAL" ]; then
  echo "Avance 1 completo. Tu pipeline arma correctamente las 5 etapas y"
  echo "bloquea cuando corresponde. Usa estos hallazgos reales como base"
  echo "para redactar tu plan de auditoria (Avance del reto oficial, 25%)."
  exit 0
else
  echo "Aun faltan pasos, o alguna etapa no esta bien implementada. Revisa"
  echo "reportes/.orquestador_salida.txt para ver el detalle de cada etapa."
  exit 1
fi
