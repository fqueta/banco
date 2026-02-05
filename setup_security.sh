#!/bin/bash

# Script de Segurança Básica para VPS
# Executar como root

echo "=== Iniciando Configuração de Segurança ==="

# 1. Atualizar pacotes
echo "Atualizando sistema..."
apt-get update && apt-get upgrade -y

# 2. Instalar ferramentas de segurança
echo "Instalando UFW (Firewall) e Fail2Ban..."
apt-get install -y ufw fail2ban

# 3. Configurar UFW (Firewall)
echo "Configurando Firewall..."
# Definir padrão: Negar entrada, permitir saída
ufw default deny incoming
ufw default allow outgoing

# Permitir SSH (Porta 22) - IMPORTANTE
ufw allow ssh

# Permitir portas específicas se necessário (ex: 80, 443)
# ufw allow 80/tcp
# ufw allow 443/tcp
# Nota: Como estamos usando portas locais no Docker, não precisamos abrir 3306/6379/8080 externamente
# A menos que você queira acessar o PhpMyAdmin externamente, descomente a linha abaixo:
# ufw allow 8080/tcp 

# Habilitar o firewall
echo "Habilitando UFW..."
# --force para evitar prompt de confirmação
ufw --force enable

# 4. Configurar Fail2Ban
echo "Configurando Fail2Ban..."
# Copiar nossa configuração personalizada
if [ -f "jail.local" ]; then
    cp jail.local /etc/fail2ban/jail.local
    echo "Configuração personalizada do Fail2Ban aplicada."
else
    # Fallback: Criar cópia da padrão se não tivermos a personalizada
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    echo "Configuração padrão do Fail2Ban aplicada."
fi

# Reiniciar serviço para aplicar
systemctl restart fail2ban
systemctl enable fail2ban

echo "=== Configuração de Segurança Concluída ==="
echo "Status do Firewall:"
ufw status verbose
