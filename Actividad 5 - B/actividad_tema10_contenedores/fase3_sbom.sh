#!/bin/bash
# Tema 10 - Fase 3: SBOM en CycloneDX (que hay dentro de la imagen).
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes

if [ ! -x "./bin/syft" ]; then
  echo "ERROR: no existe ./bin/syft. Corre primero ./bootstrap.sh" >&2
  exit 1
fi

echo "[Fase 3] Generando el SBOM del contenido de la aplicacion (formato CycloneDX)"
SYFT_CHECK_FOR_APP_UPDATE=false ./bin/syft dir:servicio_catalogo \
  -o cyclonedx-json=reportes/sbom_cyclonedx.json > reportes/fase3_sbom.txt 2>&1

COMPONENTES=$(python3 -c "
import json
d=json.load(open('reportes/sbom_cyclonedx.json'))
libs=[c for c in d.get('components',[]) if c.get('type')=='library']
print(len(libs))
" 2>/dev/null || echo 0)

echo "  -> SBOM: reportes/sbom_cyclonedx.json"
echo "  -> Librerias inventariadas: $COMPONENTES"
echo "     Un SBOM es la lista de materiales de la imagen: si manana sale una"
echo "     vulnerabilidad nueva, con esto sabes en minutos si te afecta."
