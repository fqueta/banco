#!/bin/bash

# Configurações
REMOTE_IP="84.247.139.125"
REMOTE_USER="root"
REMOTE_DIR="/opt/banco-prod"

echo "=== Iniciando Deploy para $REMOTE_IP ==="

# 1. Criar diretório remoto
echo "Criando diretório remoto..."
ssh $REMOTE_USER@$REMOTE_IP "mkdir -p $REMOTE_DIR"

# 2. Copiar arquivos de configuração
echo "Copiando arquivos de configuração..."
scp docker-compose.prod.yml $REMOTE_USER@$REMOTE_IP:$REMOTE_DIR/docker-compose.yml
scp .env.prod $REMOTE_USER@$REMOTE_IP:$REMOTE_DIR/.env
scp setup_security.sh $REMOTE_USER@$REMOTE_IP:$REMOTE_DIR/setup_security.sh
scp jail.local $REMOTE_USER@$REMOTE_IP:$REMOTE_DIR/jail.local

# 3. Executar setup remoto
echo "Executando configuração no servidor..."
ssh $REMOTE_USER@$REMOTE_IP << 'EOF'
    set -e
    cd /opt/banco-prod
    
    # Tornar script executável e rodar segurança
    chmod +x setup_security.sh
    ./setup_security.sh

    # Verificar se Docker está instalado
    if ! command -v docker &> /dev/null; then
        echo "Docker não encontrado. Instalando..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
    else
        echo "Docker já instalado."
    fi

    # Subir os containers
    echo "Subindo containers..."
    docker compose up -d --remove-orphans

    echo "Deploy concluído com sucesso!"
    echo "Status dos containers:"
    docker compose ps
EOF
