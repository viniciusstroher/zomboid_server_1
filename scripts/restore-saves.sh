#!/bin/bash
set -e

CONTAINER_NAME="zomboid_server"
CONTAINER_PATH="/root/Zomboid/Saves/Multiplayer/venizao"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/../saves/backups"

echo "============================================="
echo "  RESTAURAR SAVES DO SERVIDOR - ZOMBOID"
echo "============================================="
echo ""

if [ ! -d "${BACKUP_DIR}" ]; then
  echo "Diretorio de backups nao encontrado: ${BACKUP_DIR}"
  exit 1
fi

BACKUPS=()
while IFS= read -r -d '' file; do
  BACKUPS+=("$file")
done < <(find "${BACKUP_DIR}" -maxdepth 1 -name "venizao_saves_*.zip" -print0 | sort -z)

if [ ${#BACKUPS[@]} -eq 0 ]; then
  echo "Nenhum backup encontrado em ${BACKUP_DIR}."
  echo "Execute backup-saves.sh primeiro."
  exit 0
fi

echo "Backups disponiveis:"
echo ""
for i in "${!BACKUPS[@]}"; do
  NAME=$(basename "${BACKUPS[$i]}")
  SIZE=$(du -h "${BACKUPS[$i]}" | cut -f1)
  printf "  [%d]  %s  (%s)\n" "$((i + 1))" "${NAME}" "${SIZE}"
done
echo ""

if [ -n "$1" ]; then
  CHOICE="$1"
else
  read -r -p "Escolha o numero do backup a restaurar (ou 0 para cancelar): " CHOICE
fi

if [ -z "${CHOICE}" ] || [ "${CHOICE}" = "0" ]; then
  echo "Operacao cancelada."
  exit 0
fi

if ! [[ "${CHOICE}" =~ ^[0-9]+$ ]] || [ "${CHOICE}" -lt 1 ] || [ "${CHOICE}" -gt ${#BACKUPS[@]} ]; then
  echo "Opcao invalida."
  exit 1
fi

SELECTED="${BACKUPS[$((CHOICE - 1))]}"
SELECTED_NAME=$(basename "${SELECTED}")

echo ""
echo "Backup selecionado: ${SELECTED_NAME}"
echo ""
read -r -p "Digite 'RESTAURAR' para confirmar: " CONFIRM

if [ "${CONFIRM}" != "RESTAURAR" ]; then
  echo "Operacao cancelada."
  exit 0
fi

echo ""
echo "[Restore] Verificando se o container esta rodando..."
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "[Restore] Parando o container ${CONTAINER_NAME}..."
  docker stop "${CONTAINER_NAME}"
  CONTAINER_WAS_RUNNING=true
else
  echo "[Restore] Container ja esta parado."
  CONTAINER_WAS_RUNNING=false
fi

echo "[Restore] Removendo saves atuais..."
docker exec "${CONTAINER_NAME}" rm -rf "${CONTAINER_PATH}" 2>/dev/null || true

echo "[Restore] Extraindo backup..."
TEMP_DIR=$(mktemp -d)
unzip -q "${SELECTED}" -d "${TEMP_DIR}"

echo "[Restore] Copiando saves para o container..."
docker cp "${TEMP_DIR}/venizao" "${CONTAINER_NAME}:${CONTAINER_PATH}"

echo "[Restore] Limpando arquivos temporarios..."
rm -rf "${TEMP_DIR}"

if [ "${CONTAINER_WAS_RUNNING}" = true ]; then
  echo "[Restore] Reiniciando o container ${CONTAINER_NAME}..."
  docker start "${CONTAINER_NAME}"
fi

echo ""
echo "[Restore] Backups restaurados com sucesso!"
