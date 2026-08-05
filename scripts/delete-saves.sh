#!/bin/bash
set -e

CONTAINER_NAME="zomboid_server"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "============================================="
echo "  DELETAR SAVES DO SERVIDOR - ZOMBOID"
echo "============================================="
echo ""
echo "Container : ${CONTAINER_NAME}"
echo "Alvo      : /root/Zomboid (dentro do container)"
echo ""

if [ "$1" != "--force" ]; then
  echo "ATENCAO: Esta acao e irreversivel!"
  echo "Todos os dados em /root/Zomboid serao apagados."
  echo ""
  read -r -p "Digite 'DELETAR' para confirmar: " CONFIRM

  if [ "${CONFIRM}" != "DELETAR" ]; then
    echo "Operacao cancelada."
    exit 0
  fi
fi

echo ""
echo "[Delete] Parando o container ${CONTAINER_NAME}..."
docker stop "${CONTAINER_NAME}" 2>/dev/null || echo "[Delete] Container ja estava parado."

echo "[Delete] Removendo o container antigo..."
docker rm "${CONTAINER_NAME}" 2>/dev/null || echo "[Delete] Container ja foi removido."

echo "[Delete] Recriando o container com /root/Zomboid limpo..."
cd "${SCRIPT_DIR}/.." && docker-compose up -d

echo ""
echo "[Delete] Operacao concluida. Container recriado com /root/Zomboid limpo."
