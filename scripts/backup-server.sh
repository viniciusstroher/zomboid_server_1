#!/bin/bash
set -e

CONTAINER_NAME="zomboid_server"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/../backups"
INI_FILE="${SCRIPT_DIR}/../config/venizao.ini"

CONTAINER_PATH="/root/Zomboid"
TEMP_DIR=$(mktemp -d)

RESET_ID=$(grep -oP '^ResetID=\K\d+' "${INI_FILE}" 2>/dev/null || echo "UNKNOWN")
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
ZIP_NAME="venizao_backup_${TIMESTAMP}_ResetID-${RESET_ID}.zip"

cleanup() {
  rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

mkdir -p "${BACKUP_DIR}"

echo "[Backup] Parando o container ${CONTAINER_NAME}..."
docker stop "${CONTAINER_NAME}" 2>/dev/null || echo "[Backup] Container ja estava parado."

echo "[Backup] Copiando ${CONTAINER_PATH} do container..."
docker cp "${CONTAINER_NAME}:${CONTAINER_PATH}" "${TEMP_DIR}/Zomboid"

echo "[Backup] Gerando zip..."
cd "${TEMP_DIR}" && zip -r "${BACKUP_DIR}/${ZIP_NAME}" Zomboid

echo "[Backup] Reiniciando o container..."
docker start "${CONTAINER_NAME}"

echo "[Backup] Concluido: ${BACKUP_DIR}/${ZIP_NAME}"
ls -lh "${BACKUP_DIR}/${ZIP_NAME}"
