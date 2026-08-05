#!/bin/bash
set -e

CONTAINER_NAME="zomboid_server"
CONTAINER_PATH="/root/Zomboid/Saves/Multiplayer/venizao"
BACKUP_DIR="/home/veni/zomboid_server_1/saves/backups"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
ZIP_NAME="venizao_saves_${TIMESTAMP}.zip"
TEMP_DIR=$(mktemp -d)

echo "[Backup] Copiando saves do container ${CONTAINER_NAME}..."
docker cp "${CONTAINER_NAME}:${CONTAINER_PATH}" "${TEMP_DIR}/venizao"

mkdir -p "${BACKUP_DIR}"

echo "[Backup] Gerando zip ${ZIP_NAME}..."
cd "${TEMP_DIR}" && zip -r "${BACKUP_DIR}/${ZIP_NAME}" venizao

echo "[Backup] Limpando arquivos temporarios..."
rm -rf "${TEMP_DIR}"

echo "[Backup] Concluido: ${BACKUP_DIR}/${ZIP_NAME}"
ls -lh "${BACKUP_DIR}/${ZIP_NAME}"
