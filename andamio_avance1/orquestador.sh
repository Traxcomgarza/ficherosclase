#!/bin/bash
# Orquestador del pipeline de Avance 1 - LSCA2314
# Corre las 5 etapas en orden. La secuencia ya esta armada: tu trabajo es
# completar la logica de bloqueo al final (ver el TODO mas abajo).
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"
mkdir -p reportes

echo "=================================================="
echo " Pipeline Avance 1 del Reto - LSCA2314"
echo "=================================================="

bash pipeline/01_secretos.sh
bash pipeline/02_iac.sh
bash pipeline/03_sast_semgrep.sh
bash pipeline/04_sast_bandit.sh
bash pipeline/05_sca.sh

echo ""
echo "=================================================="
echo " Resultado de cada etapa"
echo "=================================================="

# =============================================================================
# TODO (logica de bloqueo integrada): las 5 etapas ya guardaron su codigo de
# salida en reportes/.fase1_exit ... reportes/.fase5_exit (0 = sin hallazgos,
# distinto de 0 = con hallazgos). Completa esta seccion para que:
#
#   1. Imprima el resultado de cada etapa (nombre + PASA/FALLA).
#   2. Si CUALQUIER etapa fallo, el pipeline completo debe terminar con:
#        - El mensaje exacto: DESPLIEGUE BLOQUEADO
#        - Codigo de salida 1
#   3. Si TODAS las etapas pasaron, debe terminar con:
#        - El mensaje exacto: DESPLIEGUE PERMITIDO
#        - Codigo de salida 0
#
# Pista: puedes leer cada archivo con `cat reportes/.fase1_exit`, compararlo
# con "0", y usar una variable acumuladora para saber si alguna etapa fallo.
#
# Variable acumuladora: empieza en 0 y se pone en 1 si alguna etapa falla.
HUBO_FALLA=0

# Leo el codigo de salida que guardo cada etapa.
CODIGO1=$(cat reportes/.fase1_exit)
CODIGO2=$(cat reportes/.fase2_exit)
CODIGO3=$(cat reportes/.fase3_exit)
CODIGO4=$(cat reportes/.fase4_exit)
CODIGO5=$(cat reportes/.fase5_exit)

if [ "$CODIGO1" = "0" ]; then
  echo "  Etapa 1 - Secretos (gitleaks): PASA"
else
  echo "  Etapa 1 - Secretos (gitleaks): FALLA"
  HUBO_FALLA=1
fi

if [ "$CODIGO2" = "0" ]; then
  echo "  Etapa 2 - Infraestructura (checkov): PASA"
else
  echo "  Etapa 2 - Infraestructura (checkov): FALLA"
  HUBO_FALLA=1
fi

if [ "$CODIGO3" = "0" ]; then
  echo "  Etapa 3 - SAST (semgrep): PASA"
else
  echo "  Etapa 3 - SAST (semgrep): FALLA"
  HUBO_FALLA=1
fi

if [ "$CODIGO4" = "0" ]; then
  echo "  Etapa 4 - SAST (bandit): PASA"
else
  echo "  Etapa 4 - SAST (bandit): FALLA"
  HUBO_FALLA=1
fi

if [ "$CODIGO5" = "0" ]; then
  echo "  Etapa 5 - Dependencias (pip-audit): PASA"
else
  echo "  Etapa 5 - Dependencias (pip-audit): FALLA"
  HUBO_FALLA=1
fi

echo ""

# Si al menos una etapa fallo, se bloquea el despliegue.
if [ "$HUBO_FALLA" = "1" ]; then
  echo "DESPLIEGUE BLOQUEADO"
  exit 1
else
  echo "DESPLIEGUE PERMITIDO"
  exit 0
fi
# =============================================================================
