#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SAVES_DIR="${SCRIPT_DIR}/../saves"
BACKUP_DIR="${SCRIPT_DIR}/../backups"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
ZIP_NAME="venizao_state_${TIMESTAMP}.zip"

mkdir -p "${BACKUP_DIR}"

echo "[Backup] Gerando zip da pasta state..."
if [ -d "${SAVES_DIR}" ]; then
  cd "${SAVES_DIR}" && zip -r "${BACKUP_DIR}/${ZIP_NAME}" .
else
  echo "[Backup] ERRO: Pasta state nao encontrada em ${SAVES_DIR}"
  exit 1
fi

echo "[Backup] Concluido: ${BACKUP_DIR}/${ZIP_NAME}"
ls -lh "${BACKUP_DIR}/${ZIP_NAME}"
