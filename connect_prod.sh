#!/bin/bash

# Configurações do Servidor
REMOTE_USER="root"
REMOTE_IP="84.247.139.125"

# Mapeamento de Portas (Local:Remota)
# Local 8082 -> Remota 8080 (PhpMyAdmin)
# Local 3308 -> Remota 3306 (MySQL)
# Local 6380 -> Remota 6379 (Redis)

echo "=== Iniciando Túnel Seguro para Produção ==="
echo "Acessos Locais:"
echo " - PhpMyAdmin: http://localhost:8082"
echo " - MySQL:      localhost:3308"
echo " - Redis:      localhost:6380"
echo ""
echo "Mantenha esta janela aberta para manter a conexão ativa."
echo "Pressione Ctrl+C para encerrar."
echo "============================================"

ssh -N \
    -L 8082:127.0.0.1:8080 \
    -L 3308:127.0.0.1:3306 \
    -L 6380:127.0.0.1:6379 \
    $REMOTE_USER@$REMOTE_IP
