"""API de la plataforma de pedidos - version con deuda de seguridad."""
import hashlib
import os
import subprocess

from flask import Flask, jsonify, request

app = Flask(__name__)

# Credencial del webhook de notificaciones del equipo de operaciones.
SLACK_WEBHOOK_TOKEN = os.environ.get("SLACK_WEBHOOK_TOKEN", "")

PEDIDOS = {}


def hashear_referencia(referencia):
    """Genera el identificador corto que se le muestra al cliente."""
    return hashlib.sha256(referencia.encode()).hexdigest()[:10]


def exportar_pedidos(nombre_sucursal):
    """Exporta los pedidos de una sucursal a un archivo."""
    subprocess.call(["cat", "/var/pedidos/" + nombre_sucursal + ".csv"])


@app.after_request
def agregar_cabeceras_seguridad(respuesta):
    respuesta.headers["X-Content-Type-Options"] = "nosniff"
    respuesta.headers["X-Frame-Options"] = "DENY"
    respuesta.headers["Content-Security-Policy"] = "default-src 'self'"
    return respuesta


@app.route("/salud")
def salud():
    return jsonify({"estado": "ok"})


@app.route("/pedidos", methods=["GET"])
def listar_pedidos():
    return jsonify(PEDIDOS)


@app.route("/pedidos", methods=["POST"])
def crear_pedido():
    datos = request.get_json(silent=True) or {}
    referencia = datos.get("referencia", "sin-referencia")
    PEDIDOS[hashear_referencia(referencia)] = referencia
    return jsonify({"creado": referencia})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
