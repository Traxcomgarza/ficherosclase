"""Pruebas dinamicas (DAST) contra la API de pedidos en ejecucion.

Se ejecuta desde etapas/80_dast.sh, que levanta la aplicacion antes y la
apaga despues. Cada prueba imprime PASA o FALLA. El script termina con
codigo 1 si alguna prueba critica falla.
"""
import sys

import requests

BASE = "http://127.0.0.1:5000"
CRITICAS = []
INFORMATIVAS = []


def registrar(nombre, ok, detalle, critica=True):
    estado = "PASA" if ok else "FALLA"
    print(f"  [{estado}] {nombre}: {detalle}")
    (CRITICAS if critica else INFORMATIVAS).append(ok)


def main():
    try:
        r = requests.get(f"{BASE}/salud", timeout=5)
    except requests.exceptions.RequestException as exc:
        print(f"  [FALLA] La aplicacion no responde en {BASE}: {exc}")
        return 1

    registrar("Aplicacion en linea", r.status_code == 200,
              f"/salud respondio {r.status_code}")

    cabeceras = {k.lower(): v for k, v in r.headers.items()}

    for nombre_cabecera in ("x-content-type-options", "x-frame-options",
                            "content-security-policy"):
        presente = nombre_cabecera in cabeceras
        registrar(
            f"Cabecera {nombre_cabecera}",
            presente,
            cabeceras.get(nombre_cabecera, "ausente"),
        )

    # La consola interactiva de Werkzeug solo existe con debug=True y permite
    # ejecutar codigo en el servidor.
    try:
        consola = requests.get(f"{BASE}/console", timeout=5)
        expuesta = consola.status_code == 200
    except requests.exceptions.RequestException:
        expuesta = False
    registrar("Consola de depuracion NO expuesta", not expuesta,
              "/console respondio 200 (debug activo)" if expuesta
              else "/console no esta disponible")

    # El endpoint de creacion debe seguir funcionando despues de remediar.
    try:
        creado = requests.post(f"{BASE}/pedidos",
                               json={"referencia": "PED-2026-001"}, timeout=5)
        funciona = creado.status_code == 200
    except requests.exceptions.RequestException:
        funciona = False
    registrar("La funcionalidad sigue trabajando", funciona,
              "POST /pedidos responde correctamente" if funciona
              else "POST /pedidos fallo", critica=False)

    fallidas = CRITICAS.count(False)
    print("")
    print(f"  Pruebas criticas fallidas: {fallidas}")
    return 1 if fallidas else 0


if __name__ == "__main__":
    sys.exit(main())
