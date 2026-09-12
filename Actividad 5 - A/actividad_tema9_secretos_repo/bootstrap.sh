#!/bin/bash
# Actividad de practica - Tema 9 - LSCA2314
# Deteccion de secretos en repositorios e historial de Git.
# Prepara todo con un solo comando: descarga gitleaks y TruffleHog, y crea el
# repositorio de practica CON historial (dos commits).
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "=================================================="
echo " Tema 9 - Deteccion de secretos en repositorios"
echo "=================================================="

mkdir -p bin reportes
ARCH="$(uname -m)"

echo "[1/3] Descargando gitleaks (v8.30.1)..."
if [ ! -f "bin/gitleaks" ]; then
  if [ "$ARCH" = "x86_64" ]; then GL_ARCH="x64"; else GL_ARCH="arm64"; fi
  curl -sL -o /tmp/gitleaks_t9.tar.gz \
    "https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_${GL_ARCH}.tar.gz"
  tar xzf /tmp/gitleaks_t9.tar.gz -C bin gitleaks
  chmod +x bin/gitleaks
  rm -f /tmp/gitleaks_t9.tar.gz
fi

echo "[2/3] Descargando TruffleHog (v3.97.2)..."
if [ ! -f "bin/trufflehog" ]; then
  if [ "$ARCH" = "x86_64" ]; then TH_ARCH="amd64"; else TH_ARCH="arm64"; fi
  curl -sL -o /tmp/trufflehog_t9.tar.gz \
    "https://github.com/trufflesecurity/trufflehog/releases/download/v3.97.2/trufflehog_3.97.2_linux_${TH_ARCH}.tar.gz"
  tar xzf /tmp/trufflehog_t9.tar.gz -C bin trufflehog
  chmod +x bin/trufflehog
  rm -f /tmp/trufflehog_t9.tar.gz
fi

echo "[3/3] Creando el repositorio de practica con historial..."
if [ ! -d "repo_despliegue/.git" ]; then
  rm -rf repo_despliegue
  mkdir -p repo_despliegue
  cd repo_despliegue
  git init -q

  # Commit 1: alguien sube el script CON las credenciales dentro.
  cat > despliegue_catalogo.py << 'PYEOF'
"""Sube el catalogo de productos al bucket de la tienda."""

AWS_ACCESS_KEY_ID = "AKIA4TQ7XJ2MFVQ8DKPZ"
AWS_SECRET_ACCESS_KEY = "hK3nVq8ZpR2wLxT9dYbF7mCsQ4jNgE1uWaXvB6Ro"
BUCKET = "catalogo-tienda-publico"


def subir_catalogo(ruta_csv):
    print("Subiendo", ruta_csv, "al bucket", BUCKET)
PYEOF
  cat > README.md << 'MDEOF'
# Servicio de despliegue de catalogo

Script interno que publica el catalogo de productos.
MDEOF
  git add .
  git -c user.email="dev@tienda.local" -c user.name="Dev Tienda" \
    commit -qm "script de despliegue del catalogo"

  # Commit 2: alguien "arregla" el problema quitando las credenciales del archivo.
  cat > despliegue_catalogo.py << 'PYEOF'
"""Sube el catalogo de productos al bucket de la tienda."""
import os

AWS_ACCESS_KEY_ID = os.environ["AWS_ACCESS_KEY_ID"]
AWS_SECRET_ACCESS_KEY = os.environ["AWS_SECRET_ACCESS_KEY"]
BUCKET = "catalogo-tienda-publico"


def subir_catalogo(ruta_csv):
    print("Subiendo", ruta_csv, "al bucket", BUCKET)
PYEOF
  git add .
  git -c user.email="dev@tienda.local" -c user.name="Dev Tienda" \
    commit -qm "limpieza: credenciales a variables de entorno"
  cd "$DIR"
fi

echo ""
echo "  - gitleaks:   $(./bin/gitleaks version)"
echo "  - trufflehog: $(./bin/trufflehog --version 2>&1 | head -1)"
echo "  - repositorio de practica: repo_despliegue/ ($(git -C repo_despliegue rev-list --count HEAD) commits)"

echo ""
echo "=================================================="
echo " ENTORNO LISTO"
echo "=================================================="
echo "Corre las fases en orden:"
echo "  ./fase1_arbol_de_trabajo.sh"
echo "  ./fase2_historial.sh"
echo "  ./fase3_trufflehog.sh"
echo "  ./gate_fase4.sh"
echo ""
echo "Al final completa comparacion_herramientas.csv y corre ./verificar.sh"
echo ""
