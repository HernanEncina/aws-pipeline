#!/bin/bash
set -e

cd /home/ec2-user/app

# Detener contenedor anterior
echo "Stopping existing container..."
docker stop flask-app || true
docker rm flask-app || true

# Limpiar imágenes antiguas
echo "Cleaning old images..."
docker image prune -f

# Autenticarse en ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Usar variables de CodeDeploy o ECR
if [ -z "$IMAGE_URI" ]; then
  # Fallback a build local si no hay URI de ECR
  echo "Building image locally..."
  docker build -t flask-app .
  IMAGE_URI="flask-app:latest"
else
  echo "Pulling from ECR: $IMAGE_URI"
  docker pull $IMAGE_URI
fi

# Ejecutar nuevo contenedor
echo "Running new container..."
docker run -d -p 80:5000 --name flask-app --restart always $IMAGE_URI

echo "Deployment completed successfully"
