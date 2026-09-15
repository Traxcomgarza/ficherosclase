#!/bin/bash
# Etapa 80 - Pruebas dinamicas sobre la aplicacion en ejecucion (Tema 6)
# Levanta la app, la prueba y la apaga. No deja procesos colgados.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR" || exit 1
mkdir -p reportes
# shellcheck disable=SC1091
source venv/bin/activate

echo "== Etapa 80: pruebas dinamicas contra la app en ejecucion (DAST) =="

# El token se inyecta en tiempo de ejecucion (Tema 8): nunca vive en el codigo.
export SLACK_WEBHOOK_TOKEN="${SLACK_WEBHOOK_TOKEN:-token-de-prueba-inyectado}"

cd plataforma_pedidos || exit 1
python pedidos_api.py > "$DIR/reportes/80_app.log" 2>&1 &
APP_PID=$!
cd "$DIR" || exit 1

# Esperar a que la aplicacion levante (maximo 15 s).
LISTA=0
for _ in $(seq 1 15); do
  if curl -s -o /dev/null "http://127.0.0.1:5000/salud" 2>/dev/null; then
    LISTA=1; break
  fi
  sleep 1
done

if [ "$LISTA" -eq 0 ]; then
  echo "  La aplicacion no levanto. Revisa reportes/80_app.log"
  kill "$APP_PID" 2>/dev/null
  echo "1" > reportes/.80_exit
  exit 1
fi

python etapas/probe_dast.py > reportes/80_dast.txt 2>&1
CODIGO=$?
cat reportes/80_dast.txt

kill "$APP_PID" 2>/dev/null
wait "$APP_PID" 2>/dev/null

echo "$CODIGO" > reportes/.80_exit
[ "$CODIGO" -eq 0 ] && echo "  Resultado: PASA" || echo "  Resultado: FALLA (bloquea)"
exit "$CODIGO"
