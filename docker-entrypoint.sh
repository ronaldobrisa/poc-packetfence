#!/bin/bash
set -e

CONFIG_LOCK_FILE="/var/lib/packetfence/configured.lock"

if [ ! -f "$CONFIG_LOCK_FILE" ]; then
    echo "Primeiro arranque detectado. A executar a configuração dos pacotes (dpkg --configure -a)..."
    
    dpkg --configure -a
    
    echo "Configuração concluída com sucesso."
    
    mkdir -p /var/lib/packetfence
    touch "$CONFIG_LOCK_FILE"
else
    echo "Configuração já concluída. A iniciar serviços..."
fi

exec "$@"
