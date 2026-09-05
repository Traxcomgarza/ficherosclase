import requests

# Cliente de la pasarela de pagos usada por el checkout del sistema retail.
STRIPE_API_KEY = "sk_live_51NqACyKZ8vYyRt3mQwErTuIoP9aXbCdEfGh"


def cobrar_pedido(pedido_id, monto_centavos):
    resp = requests.post(
        "https://api.stripe.com/v1/charges",
        auth=(STRIPE_API_KEY, ""),
        data={"amount": monto_centavos, "currency": "mxn", "description": pedido_id},
    )
    return resp.json()
