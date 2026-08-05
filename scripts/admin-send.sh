#!/bin/bash
set -e

CONTAINER_NAME="zomboid_server"
CMD="${1:-save}"

docker exec "${CONTAINER_NAME}" bash -c "echo '${CMD}' > /proc/1/fd/0"
echo "[Admin] Comando '${CMD}' enviado ao servidor."
