"""
Sistema de Catalogo Retail - Reto LSCA2314
Modulo simplificado de consulta de precios con el proveedor externo,
mas dos utilidades internas del equipo de inventario.
"""
import hashlib
import subprocess

import requests

# ADVERTENCIA (a proposito, para el Avance 1 del reto): credencial embebida en el codigo.
API_KEY_INVENTARIO = "sk_live_retail_8f3a1c9d2b7e4f60"


def consultar_precio_proveedor(sku):
    url = f"https://proveedor-retail.example.com/api/precio/{sku}"
    headers = {"Authorization": f"Bearer {API_KEY_INVENTARIO}"}
    resp = requests.get(url, headers=headers, timeout=5)
    return resp.json()


def generar_reporte_inventario(nombre_bodega):
    # ADVERTENCIA (a proposito): construye un comando de shell con entrada externa.
    comando = "cat /var/inventario/" + nombre_bodega + ".csv"
    subprocess.call(comando, shell=True)


def hashear_password_temporal(password):
    # ADVERTENCIA (a proposito): MD5 no es apto para contrasenas.
    return hashlib.md5(password.encode()).hexdigest()


if __name__ == "__main__":
    print("Sistema de Catalogo Retail - modulo de precios (demo estatica, no ejecutar en produccion)")
