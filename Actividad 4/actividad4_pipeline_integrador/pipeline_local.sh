#!/bin/bash
# Corre el MISMO pipeline que el Jenkinsfile, sin necesidad de Jenkins.
# Cada etapa es el mismo script que invoca Jenkins, asi que el resultado
# es identico. Sirve para trabajar rapido mientras remedias.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1

if [ ! -x "bin/gitleaks" ] || [ ! -d "venv" ]; then
  echo "ERROR: entorno incompleto. Corre primero ./bootstrap.sh" >&2
  exit 1
fi

echo "=================================================="
echo " Pipeline integrador - Plataforma de Pedidos"
echo " (mismas etapas que el Jenkinsfile)"
echo "=================================================="
echo ""

bash etapas/10_secretos_arbol.sh;    echo ""
bash etapas/20_secretos_historial.sh; echo ""
bash etapas/30_sca.sh;                echo ""
bash etapas/40_sast.sh;               echo ""

# La etapa de contenedor es CONDICIONADA: solo corre si el escaneo de
# secretos del codigo paso. No tiene sentido construir ni analizar una
# imagen a partir de un repositorio que todavia tiene credenciales dentro.
if [ "$(cat reportes/.10_exit 2>/dev/null)" = "0" ]; then
  bash etapas/50_iac.sh;    echo ""
  bash etapas/60_imagen.sh; echo ""
  bash etapas/70_sbom.sh;   echo ""
else
  echo "== Etapas 50-70 OMITIDAS =="
  echo "   El escaneo de secretos (Etapa 10) fallo: no se analiza la"
  echo "   infraestructura ni la imagen hasta que el codigo este limpio."
  echo ""
fi

bash etapas/80_dast.sh; echo ""

bash etapas/90_gate.sh
CODIGO=$?
echo ""
echo "Bitacora: reportes/audit.log   |   Notificaciones: reportes/notificaciones.log"
exit "$CODIGO"
