#!/bin/bash
set -e

CONTAINER_NAME="zomboid_server"

echo "[Admin] Conectando ao console do servidor (Ctrl+P Ctrl+Q para sair sem parar o container)..."
docker attach "${CONTAINER_NAME}"
