#!/bin/bash
# Verificacion de la Actividad 4 - Pipeline integrador - LSCA2314
# No califica la calidad de tus respuestas: comprueba que el pipeline
# realmente corre, que lo pusiste en verde y que completaste el Jenkinsfile.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1

mkdir -p reportes

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
echo " Verificacion - Actividad 4 (pipeline integrador)"
echo "=================================================="
echo ""
echo "--- Entorno ---"
check "Herramientas descargadas (gitleaks, trufflehog, trivy, syft)" \
  "[ -x bin/gitleaks ] && [ -x bin/trufflehog ] && [ -x bin/trivy ] && [ -x bin/syft ]"
check "Entorno virtual creado con las herramientas de Python" \
  "[ -f venv/bin/semgrep ] && [ -f venv/bin/bandit ] && [ -f venv/bin/pip-audit ]"
check "Repositorio con historial de Git (2 commits o mas)" \
  "[ \"\$(git -C plataforma_pedidos rev-list --count HEAD 2>/dev/null || echo 0)\" -ge 2 ]"

echo ""
echo "--- Jenkinsfile (los dos TODO) ---"
# Se evalua el Jenkinsfile SIN sus comentarios: las pistas de los bloques TODO
# mencionan los comandos esperados, y no deben contar como trabajo hecho.
grep -v '^[[:space:]]*//' Jenkinsfile > reportes/.jenkinsfile_sin_comentarios 2>/dev/null

check "TODO 1 resuelto: la etapa condicionada ya no tiene 'return false'" \
  "! grep -q 'return false' reportes/.jenkinsfile_sin_comentarios"
check "TODO 1 resuelto: la condicion lee el resultado real de la Etapa 10" \
  "grep -q 'readFile' reportes/.jenkinsfile_sin_comentarios && grep -q '\.10_exit' reportes/.jenkinsfile_sin_comentarios"
check "TODO 2 resuelto: el bloque post ya no tiene el mensaje de pendiente" \
  "! grep -q 'TODO 2: falta ejecutar' reportes/.jenkinsfile_sin_comentarios"
check "TODO 2 resuelto: la puerta de control se ejecuta en el post" \
  "grep -q '90_gate.sh' reportes/.jenkinsfile_sin_comentarios"
check "TODO 2 resuelto: se archivan todos los reportes como artefactos" \
  "grep -q \"archiveArtifacts artifacts: 'reportes/\\*\\*'\" reportes/.jenkinsfile_sin_comentarios"

echo ""
echo "--- Corriendo el pipeline completo de verdad (puede tardar 2-4 min) ---"
bash pipeline_local.sh > reportes/.verificacion_salida.txt 2>&1
PIPE_EXIT=$?

echo ""
echo "--- Resultado de cada control ---"
check "Etapa 10 (secretos en el codigo) en verde" \
  "[ -f reportes/.10_exit ] && [ \"\$(cat reportes/.10_exit)\" = '0' ]"
check "Etapa 20 (secretos en el historial) ejecutada" \
  "[ -f reportes/.20_hallazgos ]"
check "Etapa 30 (dependencias / SCA) en verde" \
  "[ -f reportes/.30_exit ] && [ \"\$(cat reportes/.30_exit)\" = '0' ]"
check "Etapa 40 (SAST) en verde" \
  "[ -f reportes/.40_exit ] && [ \"\$(cat reportes/.40_exit)\" = '0' ]"
check "Etapa 50 (infraestructura) en verde" \
  "[ -f reportes/.50_exit ] && [ \"\$(cat reportes/.50_exit)\" = '0' ]"
check "Etapa 60 (imagen de contenedor) en verde" \
  "[ -f reportes/.60_exit ] && [ \"\$(cat reportes/.60_exit)\" = '0' ]"
check "Etapa 70: SBOM generado en formato CycloneDX" \
  "python3 -c \"import json,sys;d=json.load(open('reportes/sbom_cyclonedx.json'));sys.exit(0 if d.get('bomFormat')=='CycloneDX' else 1)\" 2>/dev/null"
check "Etapa 80 (DAST) en verde" \
  "[ -f reportes/.80_exit ] && [ \"\$(cat reportes/.80_exit)\" = '0' ]"

echo ""
echo "--- Puerta de control y evidencia ---"
check "El pipeline completo termina en DESPLIEGUE PERMITIDO (codigo 0)" \
  "grep -q 'DESPLIEGUE PERMITIDO' reportes/.verificacion_salida.txt && [ '$PIPE_EXIT' -eq 0 ]"
check "La bitacora de auditoria tiene registros (reportes/audit.log)" \
  "[ -s reportes/audit.log ]"
check "Se genero la notificacion al equipo (reportes/notificaciones.log)" \
  "[ -s reportes/notificaciones.log ]"

echo ""
echo "--- Documentacion ---"
check "guia_remediacion.csv sin campos [COMPLETAR]" \
  "! grep -q '\[COMPLETAR\]' guia_remediacion.csv 2>/dev/null"
check "preguntas_de_cierre.csv sin campos [COMPLETAR]" \
  "! grep -q '\[COMPLETAR\]' preguntas_de_cierre.csv 2>/dev/null"

echo ""
echo "=================================================="
echo " Resultado: $OK / $TOTAL"
echo "=================================================="

if [ "$OK" -eq "$TOTAL" ]; then
  echo "Pipeline integrador completo y en verde."
  echo "Remediaste los ocho controles, completaste el Jenkinsfile y dejaste"
  echo "la evidencia (reportes, SBOM, bitacora y notificacion)."
  exit 0
else
  echo "Aun faltan pasos. Revisa la lista de arriba y"
  echo "reportes/.verificacion_salida.txt para el detalle del pipeline."
  exit 1
fi
