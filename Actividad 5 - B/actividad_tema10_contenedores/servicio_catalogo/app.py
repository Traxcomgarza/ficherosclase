"""API minima del servicio de catalogo (solo para la practica)."""
import yaml


def cargar_catalogo(ruta):
    with open(ruta) as f:
        return yaml.safe_load(f)


if __name__ == "__main__":
    print("servicio de catalogo listo")
