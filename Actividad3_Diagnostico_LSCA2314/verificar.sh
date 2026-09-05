#!/bin/bash
# Verificacion de la Actividad 3 - LSCA2314
# No revisa la CALIDAD de tus respuestas (eso lo hace el docente), solo que
# generaste evidencia real y que ya no quedan placeholders sin completar.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1

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

PLANTILLA="Plantilla_Actividad3_Diagnostico_LSCA2314.docx"

echo "=================================================="
echo " Verificacion - Actividad 3 (Diagnostico)"
echo "=================================================="

check "gitleaks descargado (bin/gitleaks)" "[ -x bin/gitleaks ]"
check "Trivy descargado (bin/trivy)" "[ -x bin/trivy ]"

echo ""
echo "Re-generando la evidencia para confirmar que es real..."
bash 01_escanear_secreto.sh > /dev/null 2>&1
bash 02_escanear_iac.sh > /dev/null 2>&1

check "Reporte de secretos tiene el hallazgo real (stripe-access-token)" \
  "grep -q 'stripe-access-token' reportes/01_secreto.txt 2>/dev/null"
check "Reporte de IaC tiene los 8 hallazgos reales (2 HIGH, 3 MEDIUM, 3 LOW)" \
  "grep -q 'Failures: 8 (UNKNOWN: 0, LOW: 3, MEDIUM: 3, HIGH: 2, CRITICAL: 0)' reportes/02_iac.txt 2>/dev/null"

check "No hay evidencia de haber desplegado el IaC (sin carpeta .terraform ni tfstate)" \
  "[ ! -d evidencia/.terraform ] && ! find evidencia -name '*.tfstate*' | grep -q ."

echo ""
echo "Revisando la plantilla de entrega ($PLANTILLA)..."

check "La plantilla de entrega existe" "[ -f \"$PLANTILLA\" ]"

if [ -f "$PLANTILLA" ]; then
  RESTANTES=$(unzip -p "$PLANTILLA" word/document.xml 2>/dev/null | grep -o "COMPLETA AQU" | wc -l)
  check "No quedan placeholders [COMPLETA AQUÍ] sin llenar (quedan: $RESTANTES)" "[ \"$RESTANTES\" -eq 0 ]"

  IMAGENES=$(unzip -l "$PLANTILLA" 2>/dev/null | grep "word/media/" | grep -vc "/$")
  check "Se insertó el diagrama DESPUÉS (hay más de 1 imagen en el documento, encontradas: $IMAGENES)" \
    "[ \"$IMAGENES\" -gt 1 ]"
fi

echo ""
echo "=================================================="
echo " Resultado: $OK / $TOTAL"
echo "=================================================="

if [ "$OK" -eq "$TOTAL" ]; then
  echo "Evidencia generada y plantilla completa. Recuerda que esto NO califica"
  echo "la calidad de tus respuestas, solo que hiciste el trabajo con evidencia"
  echo "real. Sube: la plantilla, reportes/01_secreto.txt y reportes/02_iac.txt."
  exit 0
else
  echo "Aun faltan pasos. Revisa la lista de arriba."
  exit 1
fi
