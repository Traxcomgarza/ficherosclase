#!/bin/bash
# Actividad 3 - Fase 2: escaneo ESTATICO de evidencia/insecure_retail_iac.tf
# Importante: este script NUNCA ejecuta `terraform apply` ni despliega nada.
# El analisis es solo lectura del archivo .tf.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes

if [ ! -x "./bin/trivy" ]; then
  echo "ERROR: no existe ./bin/trivy. Corre primero ./bootstrap.sh" >&2
  exit 1
fi

echo "[Fase 2] Escaneando evidencia/insecure_retail_iac.tf con Trivy (config, sin desplegar nada)..."
./bin/trivy config evidencia/ > reportes/02_iac.txt 2>&1
EXIT_CODE=$?

echo "  -> Reporte guardado en reportes/02_iac.txt (codigo de salida $EXIT_CODE)"
echo "  -> Usa estos hallazgos reales para la seccion de Arquitectura de la"
echo "     plantilla de entrega."
