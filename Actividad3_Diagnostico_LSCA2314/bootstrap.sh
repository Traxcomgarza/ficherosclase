#!/bin/bash
# Actividad 3 (oficial) - Temas 7 y 8 - LSCA2314
# Descarga gitleaks y Trivy como binarios fijos (sin Docker). NO instala
# nada mas y NO despliega infraestructura - la Actividad 3 es diagnostico,
# no ejecucion de un pipeline.
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "=================================================="
echo " Actividad 3 - Diagnostico, respuesta a incidentes"
echo " y arquitectura - LSCA2314"
echo "=================================================="

mkdir -p bin reportes

ARCH="$(uname -m)"

echo "[1/2] Descargando gitleaks (v8.30.1)..."
if [ ! -f "bin/gitleaks" ]; then
  if [ "$ARCH" = "x86_64" ]; then GL_ARCH="x64"; else GL_ARCH="arm64"; fi
  curl -sL -o /tmp/gitleaks.tar.gz \
    "https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_${GL_ARCH}.tar.gz"
  tar xzf /tmp/gitleaks.tar.gz -C bin gitleaks
  chmod +x bin/gitleaks
  rm -f /tmp/gitleaks.tar.gz
fi

echo "[2/2] Descargando Trivy (v0.74.0)..."
if [ ! -f "bin/trivy" ]; then
  if [ "$ARCH" = "x86_64" ]; then TR_ARCH="Linux-64bit"; else TR_ARCH="Linux-ARM64"; fi
  curl -sL -o /tmp/trivy.tar.gz \
    "https://github.com/aquasecurity/trivy/releases/download/v0.74.0/trivy_0.74.0_${TR_ARCH}.tar.gz"
  tar xzf /tmp/trivy.tar.gz -C bin trivy
  chmod +x bin/trivy
  rm -f /tmp/trivy.tar.gz
fi

echo ""
echo "  - gitleaks: $(./bin/gitleaks version)"
echo "  - trivy:    $(./bin/trivy --version | head -1)"

echo ""
echo "=================================================="
echo " ENTORNO LISTO"
echo "=================================================="
echo "Siguiente paso:"
echo "  ./01_escanear_secreto.sh"
echo "  ./02_escanear_iac.sh"
echo ""
echo "Con esa evidencia real (no inventada) completas la plantilla de"
echo "entrega: Plantilla_Actividad3_Diagnostico_LSCA2314.docx"
echo ""
