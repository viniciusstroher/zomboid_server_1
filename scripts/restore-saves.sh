#!/bin/bash
set -e

CONTAINER_NAME="zomboid_server"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/../backups"
CONTAINER_PATH="/root/Zomboid"

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
done < <(find "${BACKUP_DIR}" -maxdepth 1 -name "venizao_backup_*.zip" -print0 | sort -z)

if [ ${#BACKUPS[@]} -eq 0 ]; then
  echo "Nenhum backup encontrado em ${BACKUP_DIR}."
  echo "Execute scripts/backup-saves.sh primeiro."
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

TEMP_DIR=$(mktemp -d)
cleanup() {
  rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

echo ""
echo "[Restore] Parando o container ${CONTAINER_NAME}..."
docker stop "${CONTAINER_NAME}" 2>/dev/null || echo "[Restore] Container ja estava parado."

echo "[Restore] Extraindo backup..."
unzip -q "${SELECTED}" -d "${TEMP_DIR}"

echo "[Restore] Removendo container antigo..."
docker rm "${CONTAINER_NAME}" 2>/dev/null || echo "[Restore] Container ja foi removido."

echo "[Restore] Recriando container limpo..."
cd "${SCRIPT_DIR}/.." && docker-compose create zomboid

echo "[Restore] Copiando dados para ${CONTAINER_PATH}..."
docker cp "${TEMP_DIR}/Zomboid/." "${CONTAINER_NAME}:${CONTAINER_PATH}/"

echo "[Restore] Ligando o servidor..."
docker start "${CONTAINER_NAME}"

echo ""
echo "[Restore] Backup restaurado com sucesso! Servidor iniciado."
