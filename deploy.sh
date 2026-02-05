#!/bin/bash

# Configurações
REMOTE_IP="84.247.139.125"
REMOTE_USER="root"
REMOTE_DIR="/opt/banco-prod"
TEMP_DIR="deploy_pkg"

echo "=== Iniciando Deploy Otimizado para $REMOTE_IP ==="

# 1. Preparar pacote localmente
echo "Preparando arquivos..."
rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR

# Copiar e renomear arquivos para o pacote
cp docker-compose.prod.yml $TEMP_DIR/docker-compose.yml
cp .env.prod $TEMP_DIR/.env
cp setup_security.sh $TEMP_DIR/
cp jail.local $TEMP_DIR/

# 2. Enviar e Executar em UMA única conexão (Apenas 1 senha!)
echo "Enviando e executando no servidor (Digite a senha apenas 1 vez)..."

tar czf - -C $TEMP_DIR . | ssh $REMOTE_USER@$REMOTE_IP "
    set -e
    # Criar diretório se não existir
    mkdir -p $REMOTE_DIR
    cd $REMOTE_DIR
    
    # Extrair arquivos recebidos
    echo 'Extraindo arquivos...'
    tar xzf -
    
    # Executar script de segurança
    echo 'Configurando segurança...'
    chmod +x setup_security.sh
    ./setup_security.sh

    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        echo 'Docker não encontrado. Instalando...'
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
    fi

    # Subir containers
    echo 'Subindo containers...'
    docker compose up -d --remove-orphans

    echo 'Deploy concluído com sucesso!'
    echo 'Status dos containers:'
    docker compose ps
"

# Limpeza local
rm -rf $TEMP_DIR
