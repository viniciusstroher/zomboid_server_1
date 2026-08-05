#!/bin/bash
set -e

CONTAINER_NAME="zomboid_server"
CONTAINER_PATH="/root/Zomboid/Saves/Multiplayer/venizao"

echo "============================================="
echo "  DELETAR SAVES DO SERVIDOR - ZOMBOID"
echo "============================================="
echo ""
echo "Container : ${CONTAINER_NAME}"
echo "Save path : ${CONTAINER_PATH}"
echo ""

if [ "$1" != "--force" ]; then
  echo "ATENCAO: Esta acao e irreversivel!"
  echo "Todos os saves do servidor serao apagados permanentemente."
  echo ""
  read -r -p "Digite 'DELETAR' para confirmar: " CONFIRM

  if [ "${CONFIRM}" != "DELETAR" ]; then
    echo "Operacao cancelada."
    exit 0
  fi
fi

echo ""
echo "[Delete] Verificando se o container esta rodando..."
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "[Delete] Parando o container ${CONTAINER_NAME}..."
  docker stop "${CONTAINER_NAME}"
  CONTAINER_WAS_RUNNING=true
else
  echo "[Delete] Container ja esta parado."
  CONTAINER_WAS_RUNNING=false
fi

SAVES_DIR="$(dirname "$(readlink -f "$0")")/../saves"
echo "[Delete] Removendo saves da pasta state (${SAVES_DIR})..."
if [ -d "${SAVES_DIR}" ]; then
  rm -rf "${SAVES_DIR}"
  echo "[Delete] Pasta state removida com sucesso."
else
  echo "[Delete] Nenhuma pasta state encontrada para remover."
fi

if [ "${CONTAINER_WAS_RUNNING}" = true ]; then
  echo "[Delete] Reiniciando o container ${CONTAINER_NAME}..."
  docker start "${CONTAINER_NAME}"
  echo "[Delete] Container reiniciado. O servidor criara novos saves automaticamente."
fi

echo ""
echo "[Delete] Operacao concluida."
