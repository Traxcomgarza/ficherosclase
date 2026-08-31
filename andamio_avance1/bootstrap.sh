#!/bin/bash
# Andamio Avance 1 del Reto - LSCA2314
# Prepara el entorno: venv con checkov + pip-audit + semgrep + bandit, y el
# binario de gitleaks. NO completa el pipeline por ti - eso lo haces en
# pipeline/01_secretos.sh ... 05_sca.sh y en orquestador.sh.
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"
export SEMGREP_SEND_METRICS=off

echo "=================================================="
echo " Andamio Avance 1 del Reto - LSCA2314"
echo "=================================================="

echo "[1/4] Creando entorno virtual de Python..."
if [ ! -d "venv" ]; then
  python3 -m venv venv
fi
source venv/bin/activate

echo "[2/4] Instalando checkov, pip-audit, semgrep y bandit (1-3 minutos)..."
pip install --quiet --disable-pip-version-check --upgrade pip
pip install --quiet --disable-pip-version-check checkov==3.3.15 pip-audit==2.10.1 semgrep bandit

echo "[3/4] Descargando gitleaks (binario fijo v8.30.1)..."
mkdir -p bin
if [ ! -f "bin/gitleaks" ]; then
  ARCH="$(uname -m)"
  if [ "$ARCH" = "x86_64" ]; then
    GL_ARCH="x64"
  elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    GL_ARCH="arm64"
  else
    echo "Arquitectura no reconocida: $ARCH"; exit 1
  fi
  curl -sL -o /tmp/gitleaks.tar.gz \
    "https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_${GL_ARCH}.tar.gz"
  tar xzf /tmp/gitleaks.tar.gz -C bin gitleaks
  chmod +x bin/gitleaks
  rm -f /tmp/gitleaks.tar.gz
fi

echo "[4/4] Verificando versiones instaladas..."
echo "  - checkov:   $(checkov --version)"
echo "  - pip-audit: $(pip-audit --version)"
echo "  - semgrep:   $(SEMGREP_SEND_METRICS=off semgrep --version --disable-version-check)"
echo "  - bandit:    $(bandit --version 2>&1 | head -1)"
echo "  - gitleaks:  $(./bin/gitleaks version)"

mkdir -p reportes

echo ""
echo "=================================================="
echo " ENTORNO LISTO (el pipeline AUN NO esta completo)"
echo "=================================================="
echo "Repositorio de practica: repo_reto/ (Sistema de Catalogo Retail)"
echo ""
echo "Cada archivo en pipeline/ tiene un bloque TODO que debes completar:"
echo "  pipeline/01_secretos.sh       (gitleaks)"
echo "  pipeline/02_iac.sh            (checkov)"
echo "  pipeline/03_sast_semgrep.sh   (semgrep)"
echo "  pipeline/04_sast_bandit.sh    (bandit)"
echo "  pipeline/05_sca.sh            (pip-audit)"
echo "  orquestador.sh                (logica de bloqueo integrada)"
echo ""
echo "Cuando termines cada uno, corre:"
echo "  source venv/bin/activate"
echo "  ./orquestador.sh"
echo ""
echo "Al final: completa guia_hallazgos.csv y corre ./verificar.sh"
echo ""
