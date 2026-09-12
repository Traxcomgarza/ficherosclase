#!/bin/bash
# Actividad de practica - Tema 10 - LSCA2314
# Seguridad de imagenes de contenedor: Dockerfile, SBOM y dependencias.
# NO necesita Docker instalado: todo el analisis es estatico.
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "=================================================="
echo " Tema 10 - Seguridad de imagenes de contenedor"
echo "=================================================="

mkdir -p bin reportes
ARCH="$(uname -m)"

echo "[1/3] Descargando Trivy (v0.74.0)..."
if [ ! -f "bin/trivy" ]; then
  if [ "$ARCH" = "x86_64" ]; then TR_ARCH="Linux-64bit"; else TR_ARCH="Linux-ARM64"; fi
  curl -sL -o /tmp/trivy_t10.tar.gz \
    "https://github.com/aquasecurity/trivy/releases/download/v0.74.0/trivy_0.74.0_${TR_ARCH}.tar.gz"
  tar xzf /tmp/trivy_t10.tar.gz -C bin trivy
  chmod +x bin/trivy
  rm -f /tmp/trivy_t10.tar.gz
fi

echo "[2/3] Descargando syft (v1.29.0) para generar el SBOM..."
if [ ! -f "bin/syft" ]; then
  if [ "$ARCH" = "x86_64" ]; then SY_ARCH="amd64"; else SY_ARCH="arm64"; fi
  curl -sL -o /tmp/syft_t10.tar.gz \
    "https://github.com/anchore/syft/releases/download/v1.29.0/syft_1.29.0_linux_${SY_ARCH}.tar.gz"
  tar xzf /tmp/syft_t10.tar.gz -C bin syft
  chmod +x bin/syft
  rm -f /tmp/syft_t10.tar.gz
fi

echo "[3/3] Instalando pip-audit en un entorno virtual..."
if [ ! -d "venv" ]; then
  python3 -m venv venv
fi
# shellcheck disable=SC1091
source venv/bin/activate
pip install --quiet --disable-pip-version-check --upgrade pip
pip install --quiet --disable-pip-version-check pip-audit==2.9.0

echo ""
echo "  - trivy:     $(./bin/trivy --version | head -1)"
echo "  - syft:      $(SYFT_CHECK_FOR_APP_UPDATE=false ./bin/syft version 2>/dev/null | grep Version | head -1)"
echo "  - pip-audit: $(pip-audit --version)"

echo ""
echo "=================================================="
echo " ENTORNO LISTO"
echo "=================================================="
echo "Corre las fases en orden:"
echo "  ./fase1_dockerfile.sh        (que esta mal en la imagen)"
echo "  ./fase2_endurecer.sh         (corrige Dockerfile.endurecido y vuelve a correrla)"
echo "  ./fase3_sbom.sh              (SBOM en CycloneDX)"
echo "  ./fase4_dependencias.sh      (que vulnerabilidades entran en la imagen)"
echo ""
echo "Al final completa guia_hallazgos.csv y corre ./verificar.sh"
echo ""
