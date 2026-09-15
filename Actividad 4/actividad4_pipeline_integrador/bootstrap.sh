#!/bin/bash
# ACTIVIDAD 4 (oficial) - Pipeline integrador de DevSecOps - LSCA2314
# Prepara TODO el entorno con un solo comando: herramientas, entorno virtual
# y el repositorio de la plataforma de pedidos con su historial de Git.
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "=================================================="
echo " Actividad 4 - Pipeline integrador de DevSecOps"
echo " Plataforma de Pedidos - LSCA2314"
echo "=================================================="

mkdir -p bin reportes
ARCH="$(uname -m)"

descargar_github() {
  local nombre="$1" url="$2" archivo_en_tar="$3"
  if [ -f "bin/$nombre" ]; then return 0; fi
  curl -sL -o "/tmp/a4_${nombre}.tar.gz" "$url"
  tar xzf "/tmp/a4_${nombre}.tar.gz" -C bin "$archivo_en_tar"
  chmod +x "bin/$nombre"
  rm -f "/tmp/a4_${nombre}.tar.gz"
}

echo "[1/4] Descargando herramientas (gitleaks, TruffleHog, Trivy, syft)..."
if [ "$ARCH" = "x86_64" ]; then
  GL_ARCH="x64"; TH_ARCH="amd64"; TR_ARCH="Linux-64bit"; SY_ARCH="amd64"
else
  GL_ARCH="arm64"; TH_ARCH="arm64"; TR_ARCH="Linux-ARM64"; SY_ARCH="arm64"
fi

descargar_github gitleaks \
  "https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_${GL_ARCH}.tar.gz" gitleaks
descargar_github trufflehog \
  "https://github.com/trufflesecurity/trufflehog/releases/download/v3.97.2/trufflehog_3.97.2_linux_${TH_ARCH}.tar.gz" trufflehog
descargar_github trivy \
  "https://github.com/aquasecurity/trivy/releases/download/v0.74.0/trivy_0.74.0_${TR_ARCH}.tar.gz" trivy
descargar_github syft \
  "https://github.com/anchore/syft/releases/download/v1.29.0/syft_1.29.0_linux_${SY_ARCH}.tar.gz" syft

echo "[2/4] Creando entorno virtual (semgrep, bandit, pip-audit, Flask)..."
echo "      Esto puede tardar 2-3 minutos la primera vez."
if [ ! -d "venv" ]; then
  python3.11 -m venv venv
fi
# shellcheck disable=SC1091
source venv/bin/activate
pip install --quiet --disable-pip-version-check --upgrade pip
pip install --quiet --disable-pip-version-check semgrep bandit pip-audit==2.9.0 flask requests

echo "[3/4] Creando el repositorio de la plataforma con su historial..."
if [ ! -d "plataforma_pedidos/.git" ]; then
  cd plataforma_pedidos

  # Historial: primero alguien subio el script de despliegue CON la llave dentro.
  mkdir -p scripts
  cat > scripts/desplegar.sh << 'HISTEOF'
#!/bin/bash
# Publica la plataforma de pedidos en el bucket de exportacion.
AWS_ACCESS_KEY_ID="AKIA7RQ2WMKX9TLPBVDF"
AWS_SECRET_ACCESS_KEY="pR7mKq2XvT9wLbY4nZcF8dHjG1sQeU6aVxNoB3Ri"
aws s3 sync ./export s3://plataforma-pedidos-export
HISTEOF

  git init -q
  git add .
  git -c user.email="dev@plataforma.local" -c user.name="Dev Pedidos" \
    commit -qm "configuracion inicial del despliegue de la plataforma"

  # Segundo commit: "limpian" la llave del archivo... pero ya quedo en el historial.
  cat > scripts/desplegar.sh << 'HISTEOF'
#!/bin/bash
# Publica la plataforma de pedidos en el bucket de exportacion.
# Las credenciales se inyectan desde el gestor de secretos (ver Tema 8).
aws s3 sync ./export s3://plataforma-pedidos-export
HISTEOF
  git add .
  git -c user.email="dev@plataforma.local" -c user.name="Dev Pedidos" \
    commit -qm "limpieza: quitar credenciales del script de despliegue"

  cd "$DIR"
fi

echo "[4/4] Verificando versiones..."
echo "  - gitleaks:   $(./bin/gitleaks version)"
echo "  - trufflehog: $(./bin/trufflehog --version 2>&1 | head -1)"
echo "  - trivy:      $(./bin/trivy --version | head -1)"
echo "  - syft:       $(SYFT_CHECK_FOR_APP_UPDATE=false ./bin/syft version 2>/dev/null | grep Version | head -1)"
echo "  - semgrep:    $(SEMGREP_SEND_METRICS=off semgrep --version --disable-version-check 2>/dev/null)"
echo "  - bandit:     $(bandit --version 2>&1 | head -1)"
echo "  - pip-audit:  $(pip-audit --version)"
echo "  - repositorio: plataforma_pedidos/ ($(git -C plataforma_pedidos rev-list --count HEAD) commits)"

echo ""
echo "=================================================="
echo " ENTORNO LISTO"
echo "=================================================="
echo "Corre el pipeline completo:"
echo "  ./pipeline_local.sh"
echo ""
echo "La primera corrida DEBE terminar en DESPLIEGUE BLOQUEADO."
echo "Tu trabajo es remediar los hallazgos hasta ponerlo en verde,"
echo "y completar los dos bloques TODO del Jenkinsfile."
echo ""
