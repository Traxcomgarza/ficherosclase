#!/bin/bash
# Publica la plataforma de pedidos en el bucket de exportacion.
# Las credenciales se inyectan desde el gestor de secretos (ver Tema 8).
aws s3 sync ./export s3://plataforma-pedidos-export
