#!/bin/bash
# deploy-remote.sh - Este script se ejecuta en EC2

set -e

echo "=== Starting deploy on EC2 ==="

cd /home/ec2-user

# Clonar o actualizar
if [ -d "app" ]; then
    echo "Pulling latest code..."
    cd app
    git pull origin main
else
    echo "Cloning repository..."
    git clone https://github.com/HernanEncina/aws-pipeline.git app
    cd app
fi

# Construir imagen
echo "Building Docker image..."
docker build -t flask-app ./app

# Reemplazar contenedor
echo "Replacing container..."
docker stop flask-app 2>/dev/null || true
docker rm flask-app 2>/dev/null || true
docker run -d -p 80:5000 --name flask-app --restart always flask-app

# Verificar
echo "Container is running:"
docker ps | grep flask-app

echo "=== Deploy completed at $(date) ==="
