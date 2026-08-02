#!/bin/bash
set -e

STEAMCMD="/opt/steamcmd/steamcmd.sh"
PZ_DIR="/opt/pzserver"
DATA_DIR="/data"
CONFIG_DIR="${DATA_DIR}/config"
SAVES_DIR="${DATA_DIR}/saves"

echo "=== Project Zomboid Dedicated Server v42.20 ==="

install_server() {
    echo "[SteamCMD] Baixando/atualizando servidor... (beta: ${STEAM_BETA:-unstable})"

    # Remove old manifest to avoid beta conflicts
    if [ -f "${PZ_DIR}/steamapps/appmanifest_${STEAM_APPID}.acf" ]; then
        local current_beta
        current_beta=$(grep -oP '"BetaKey"\s+"\K[^"]+' "${PZ_DIR}/steamapps/appmanifest_${STEAM_APPID}.acf" | head -1)
        if [ "${current_beta}" != "${STEAM_BETA:-unstable}" ]; then
            echo "[SteamCMD] Beta antiga (${current_beta}) != nova (${STEAM_BETA:-unstable}). Removendo manifest..."
            rm -f "${PZ_DIR}/steamapps/appmanifest_${STEAM_APPID}.acf"
        fi
    fi

    $STEAMCMD +force_install_dir ${PZ_DIR} \
        +login ${STEAM_USER} \
        +app_update ${STEAM_APPID} validate \
        +quit
    echo "[SteamCMD] Download concluido."
}

if [ ! -f "${PZ_DIR}/start-server.sh" ]; then
    echo "[Init] Arquivos do servidor nao encontrados. Baixando..."
    install_server
else
    echo "[Init] Atualizando servidor..."
    install_server
fi

mkdir -p "${HOME}/Zomboid"
if [ ! -L "${HOME}/Zomboid/Server" ]; then
    mkdir -p "${CONFIG_DIR}" "${SAVES_DIR}"

    if [ ! -f "${CONFIG_DIR}/${SERVER_NAME}.ini" ]; then
        echo "[Config] Criando configuracao padrao: ${SERVER_NAME}.ini"
        cat > "${CONFIG_DIR}/${SERVER_NAME}.ini" << INIEOF
servername=${SERVER_NAME}
RCONPort=27015
Password=
MaxPlayers=${SERVER_MAX_PLAYERS}
PingLimit=400
HoursForLootRespawn=0
MaxItemsForLootRespawn=4
PVP=false
PauseEmpty=true
GlobalChat=true
Open=${SERVER_PUBLIC}
ServerWelcomeMessage=Welcome to Project Zomboid Server!<br>Build 42.20<br>Have fun!
LogLocalChat=true
AutoCreateUserInWhiteList=false
DisplayUserName=false
SpawnPoint=0,0,0
SafetySystem=true
ShowSafety=true
SafetyToggleTimer=2
SafetyCooldownTimer=3
KickFastPlayers=false
MaxAccountsPerUser=1
LootRespawn=false
SleepAllowed=true
SleepNeeded=false
AnnounceDeath=true
MinutesPerPage=1.0
PlayerSaveOnDanger=false
SaveWorldEveryMinutes=10
PlayerSafehouse=true
SafehouseAllowTrepass=false
SafehouseAllowFire=true
SafehouseAllowLoot=true
SafehouseAllowRespawn=false
SafehouseDaySurvivedToClaim=5
SafeHouseRemovalTime=144
AllowDestructionBySledgehammer=true
INIEOF
    fi

    mkdir -p "${HOME}/Zomboid"
    ln -sf "${DATA_DIR}" "${HOME}/Zomboid/Server"
    echo "[Config] Link simbolico criado: ~/Zomboid/Server -> ${DATA_DIR}"
fi

echo "[Server] Verificando permissoes..."
chmod +x "${PZ_DIR}/start-server.sh" 2>/dev/null || true
chmod +x "${PZ_DIR}/jre64/bin/java" 2>/dev/null || true

echo "108600" > "${PZ_DIR}/steam_appid.txt"

echo "[Server] Iniciando Project Zomboid Dedicated Server 42.20..."
echo "[Server] Nome: ${SERVER_NAME}"
echo "[Server] Porta: ${SERVER_PORT}"
echo "[Server] Max Jogadores: ${SERVER_MAX_PLAYERS}"
echo "[Server] Admin Password: ${SERVER_ADMIN_PASSWORD}"
echo ""

cd "${PZ_DIR}"
exec bash start-server.sh \
    -servername "${SERVER_NAME}" \
    -adminpassword "${SERVER_ADMIN_PASSWORD}" \
    -port "${SERVER_PORT}"
