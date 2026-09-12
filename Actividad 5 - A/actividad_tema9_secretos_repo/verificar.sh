#!/bin/bash
# Verificacion de la actividad del Tema 9 - LSCA2314
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

echo "=================================================="
echo " Verificacion - Tema 9 (secretos en repositorios)"
echo "=================================================="

check "gitleaks descargado (bin/gitleaks)" "[ -x bin/gitleaks ]"
check "TruffleHog descargado (bin/trufflehog)" "[ -x bin/trufflehog ]"
check "Repositorio de practica creado con historial (2 commits)" \
  "[ \"\$(git -C repo_despliegue rev-list --count HEAD 2>/dev/null)\" = '2' ]"

echo ""
echo "Volviendo a correr las 3 fases para comprobar el comportamiento real..."
bash fase1_arbol_de_trabajo.sh > /dev/null 2>&1
bash fase2_historial.sh > /dev/null 2>&1
bash fase3_trufflehog.sh > /dev/null 2>&1

check "Fase 1: el arbol de trabajo sale LIMPIO (asi debe ser: es la trampa)" \
  "grep -q 'no leaks found' reportes/fase1_arbol.txt 2>/dev/null"
check "Fase 2: el historial SI revela el secreto (gitleaks, regla generic-api-key)" \
  "grep -q 'generic-api-key' reportes/fase2_historial.txt 2>/dev/null"
check "Fase 2: gitleaks termino con codigo de salida distinto de 0" \
  "[ -f reportes/.fase2_exit ] && [ -s reportes/.fase2_exit ] && [ \"\$(cat reportes/.fase2_exit)\" != '0' ]"
check "Fase 3: TruffleHog identifico la llave de AWS por su tipo de detector" \
  "grep -q 'Detector Type: AWS' reportes/fase3_trufflehog.txt 2>/dev/null"

echo ""
echo "Probando la puerta de control (gate)..."
bash gate_fase4.sh > reportes/.gate_salida.txt 2>&1
GATE_EXIT=$?
check "El gate bloquea correctamente (DESPLIEGUE BLOQUEADO, codigo 1)" \
  "grep -q 'DESPLIEGUE BLOQUEADO' reportes/.gate_salida.txt && [ '$GATE_EXIT' -eq 1 ]"

check "comparacion_herramientas.csv sin campos [COMPLETAR]" \
  "! grep -q '\[COMPLETAR\]' comparacion_herramientas.csv 2>/dev/null"

echo ""
echo "=================================================="
echo " Resultado: $OK / $TOTAL"
echo "=================================================="

if [ "$OK" -eq "$TOTAL" ]; then
  echo "Actividad completa. Comprobaste con evidencia real que un secreto"
  echo "borrado del codigo sigue vivo en el historial, y que dos herramientas"
  echo "distintas no ven exactamente lo mismo."
  exit 0
else
  echo "Aun faltan pasos. Revisa la lista de arriba."
  exit 1
fi
