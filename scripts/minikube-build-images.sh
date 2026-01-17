set -e

echo "pointing docker to minikube..."
eval $(minikube docker-env)

echo "building images..."
docker build -t demo-server:1 ./server
docker build -t demo-client:1 ./client
docker build -t demo-consumer:1 ./consumer

echo "verifying images..."
docker images | grep demo || { echo "images not found"; exit 1; }

echo "build complete"

