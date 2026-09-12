#!/bin/bash
# Verificacion de la actividad del Tema 10 - LSCA2314
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
echo " Verificacion - Tema 10 (imagenes de contenedor)"
echo "=================================================="

check "Trivy descargado (bin/trivy)" "[ -x bin/trivy ]"
check "syft descargado (bin/syft)" "[ -x bin/syft ]"
check "Entorno virtual con pip-audit (venv/)" "[ -f venv/bin/pip-audit ]"

echo ""
echo "Volviendo a correr las 4 fases para comprobar el comportamiento real..."
bash fase1_dockerfile.sh > /dev/null 2>&1
bash fase2_endurecer.sh > /dev/null 2>&1
bash fase3_sbom.sh > /dev/null 2>&1
bash fase4_dependencias.sh > /dev/null 2>&1

check "Fase 1: Trivy detecto los 5 hallazgos del Dockerfile original" \
  "[ \"\$(python3 -c \"import json;d=json.load(open('reportes/fase1_dockerfile.json'));print(sum(len(r.get('Misconfigurations',[])) for r in d.get('Results',[])))\" 2>/dev/null)\" = '5' ]"
check "Fase 1: uno de los hallazgos es el secreto en ENV (DS-0031, CRITICAL)" \
  "grep -q 'DS-0031' reportes/fase1_dockerfile.txt 2>/dev/null"

check "Fase 2: Dockerfile.endurecido ya no tiene TODO pendientes" \
  "! grep -q '^# TODO' Dockerfile.endurecido"
check "Fase 2: Dockerfile.endurecido pasa el escaneo con 0 hallazgos" \
  "[ -f reportes/.fase2_total ] && [ \"\$(cat reportes/.fase2_total)\" = '0' ]"

check "Fase 3: el SBOM es CycloneDX valido" \
  "python3 -c \"import json,sys;d=json.load(open('reportes/sbom_cyclonedx.json'));sys.exit(0 if d.get('bomFormat')=='CycloneDX' else 1)\" 2>/dev/null"
check "Fase 3: el SBOM inventario las 3 librerias del servicio" \
  "[ \"\$(python3 -c \"import json;d=json.load(open('reportes/sbom_cyclonedx.json'));print(len([c for c in d.get('components',[]) if c.get('type')=='library']))\" 2>/dev/null)\" = '3' ]"

check "Fase 4: pip-audit encontro vulnerabilidades reales en las dependencias" \
  "grep -q 'known vulnerabilities' reportes/fase4_dependencias.txt 2>/dev/null"

check "guia_hallazgos.csv sin campos [COMPLETAR]" \
  "! grep -q '\[COMPLETAR\]' guia_hallazgos.csv 2>/dev/null"

echo ""
echo "=================================================="
echo " Resultado: $OK / $TOTAL"
echo "=================================================="

if [ "$OK" -eq "$TOTAL" ]; then
  echo "Actividad completa. Endureciste la imagen de 5 hallazgos a 0, generaste"
  echo "su SBOM en CycloneDX y comprobaste que las dependencias que iban dentro"
  echo "tenian vulnerabilidades conocidas."
  exit 0
else
  echo "Aun faltan pasos. Revisa la lista de arriba."
  exit 1
fi
