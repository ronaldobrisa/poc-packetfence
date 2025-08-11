#!/bin/bash
set -e

LOG_FILE="/var/log/pf-install.log"

# Função para logar com timestamp
log() {
    echo "$(date '+%F %T') - $1" | tee -a "$LOG_FILE"
}

log "Entrypoint iniciado"

CONFIG_LOCK_FILE="/var/lib/packetfence/configured.lock"

if [ ! -f "$CONFIG_LOCK_FILE" ]; then
    log "Primeira inicialização detectada. Iniciando configuração dos pacotes .deb..."

    # Instalar pacotes .deb
    if [ -d "/tmp/deps" ]; then
        cd /tmp/deps || { log "Erro: não foi possível acessar /tmp/deps"; exit 1; }
        for i in {1..5}; do
            log "Tentativa $i de instalação dos pacotes .deb"
            dpkg -i *.deb && break || {
                log "Falha na instalação, tentando corrigir dependências"
                apt-get install -f -y
            }
        done
    else
        log "Diretório /tmp/deps não encontrado. Abortando."
        exit 1
    fi

    log "Configuração dos pacotes concluída."

    # Criar arquivo de lock para não repetir a configuração
    mkdir -p /var/lib/packetfence
    touch "$CONFIG_LOCK_FILE"
else
    log "Configuração já concluída. Pulando instalação."
fi

# Verificar existência dos binários e iniciar serviços
PF_MARIADB_BIN="/usr/sbin/packetfence-mariadb"
PF_BIN="/usr/sbin/packetfence"

if [ ! -x "$PF_MARIADB_BIN" ]; then
    log "Erro: binário $PF_MARIADB_BIN não encontrado ou não executável!"
    tail -f "$LOG_FILE"
    exit 1
fi

if [ ! -x "$PF_BIN" ]; then
    log "Erro: binário $PF_BIN não encontrado ou não executável!"
    tail -f "$LOG_FILE"
    exit 1
fi

log "Iniciando $PF_MARIADB_BIN"
"$PF_MARIADB_BIN" &

log "Iniciando $PF_BIN"
"$PF_BIN"

log "PacketFence iniciado com sucesso."

# Manter o container rodando para evitar restart
tail -f "$LOG_FILE"
