#!/bin/bash
# Etapa 90 - Puerta de control integrada, bitacora y notificacion
# (Temas 1 a 4: la logica de bloqueo integrada, audit.log y la notificacion
# son justo lo que las Notas de Ensenanza senalan como error frecuente omitir)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes

MARCA="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
FALLIDAS=0
RESUMEN=""

evaluar() {
  local nombre="$1" archivo="$2" bloquea="$3"
  local codigo
  if [ -f "$archivo" ]; then codigo="$(cat "$archivo")"; else codigo="sin-ejecutar"; fi

  local estado
  if [ "$codigo" = "0" ]; then
    estado="PASA"
  elif [ "$codigo" = "sin-ejecutar" ]; then
    estado="SIN EJECUTAR"
  else
    estado="FALLA"
  fi

  if [ "$bloquea" = "si" ] && [ "$estado" != "PASA" ]; then
    FALLIDAS=$((FALLIDAS+1))
  fi

  printf "  %-42s %s\n" "$nombre" "$estado"
  RESUMEN="${RESUMEN}${MARCA} etapa=\"${nombre}\" estado=${estado} bloquea=${bloquea}\n"
}

echo "=================================================="
echo " Etapa 90: puerta de control integrada"
echo "=================================================="

evaluar "10 Secretos en el codigo"          "reportes/.10_exit" "si"
evaluar "20 Secretos en el historial"       "reportes/.20_exit" "no"
evaluar "30 Dependencias (SCA)"             "reportes/.30_exit" "si"
evaluar "40 Codigo propio (SAST)"           "reportes/.40_exit" "si"
evaluar "50 Infraestructura como codigo"    "reportes/.50_exit" "si"
evaluar "60 Imagen de contenedor"           "reportes/.60_exit" "si"
evaluar "70 SBOM (evidencia)"               "reportes/.70_exit" "no"
evaluar "80 Pruebas dinamicas (DAST)"       "reportes/.80_exit" "si"

# Bitacora de auditoria: queda constancia de cada corrida.
printf "%b" "$RESUMEN" >> reportes/audit.log

HISTORIAL="$(cat reportes/.20_hallazgos 2>/dev/null || echo 0)"
if [ "$HISTORIAL" != "0" ]; then
  echo "${MARCA} aviso=\"hay ${HISTORIAL} secreto(s) en el historial: requieren rotacion documentada\"" >> reportes/audit.log
fi

echo ""
if [ "$FALLIDAS" -gt 0 ]; then
  echo "Etapas bloqueantes que fallaron: $FALLIDAS"
  echo ""
  echo "DESPLIEGUE BLOQUEADO"
  echo "${MARCA} resultado=BLOQUEADO etapas_fallidas=${FALLIDAS}" >> reportes/audit.log
  # Notificacion simulada al canal del equipo (sin webhook real, valores ficticios)
  echo "${MARCA} [ALERTA] Pipeline de plataforma-pedidos BLOQUEADO: ${FALLIDAS} control(es) en rojo." \
    >> reportes/notificaciones.log
  exit 1
else
  echo "Todos los controles bloqueantes pasaron."
  echo ""
  echo "DESPLIEGUE PERMITIDO"
  echo "${MARCA} resultado=PERMITIDO etapas_fallidas=0" >> reportes/audit.log
  echo "${MARCA} [OK] Pipeline de plataforma-pedidos en verde: listo para desplegar." \
    >> reportes/notificaciones.log
  exit 0
fi
