#!/bin/bash
# Tema 9 - Fase 4: la puerta (gate). Asi se comporta en un pipeline real.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1

if [ ! -f "reportes/.fase2_exit" ]; then
  echo "ERROR: corre primero ./fase2_historial.sh" >&2
  exit 1
fi

EXIT_HISTORIAL=$(cat reportes/.fase2_exit)

echo "=================================================="
echo " Puerta de control: secretos en el historial"
echo "=================================================="

if [ "$EXIT_HISTORIAL" -ne 0 ]; then
  echo "Resultado del escaneo de historial: HALLAZGOS (codigo $EXIT_HISTORIAL)"
  echo ""
  echo "DESPLIEGUE BLOQUEADO"
  echo ""
  echo "Recuerda: borrar el commit NO es la solucion completa. La credencial"
  echo "debe rotarse, porque cualquiera que haya clonado el repositorio ya la tiene."
  exit 1
else
  echo "Resultado del escaneo de historial: sin hallazgos"
  echo ""
  echo "DESPLIEGUE PERMITIDO"
  exit 0
fi
