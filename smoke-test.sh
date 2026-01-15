# #!/bin/bash
# set -e

# NAMESPACE="demo"
# TIMEOUT=180

# echo "→ waiting for pods..."
# kubectl wait --for=condition=ready pod -l app=client -n $NAMESPACE --timeout=${TIMEOUT}s
# kubectl wait --for=condition=ready pod -l app=server -n $NAMESPACE --timeout=${TIMEOUT}s
# echo "✓ pods ready"

# MINIKUBE_IP=$(minikube ip)
# NODE_PORT=$(kubectl get svc client -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')
# BASE_URL="http://${MINIKUBE_IP}:${NODE_PORT}"

# echo "→ testing client at $BASE_URL..."
# CLIENT_RESPONSE=$(curl -sf $BASE_URL)
# [ -z "$CLIENT_RESPONSE" ] && echo "✗ client failed" && exit 1
# echo "✓ client ok (${#CLIENT_RESPONSE} bytes)"

# echo "→ testing api at $BASE_URL/api/button1..."
# BUTTON1=$(curl -sf $BASE_URL/api/button1)
# echo "$BUTTON1" | grep -q '"ok":true' || { echo "✗ api failed"; exit 1; }
# echo "✓ api ok: $BUTTON1"

# echo ""
# echo "✓ smoke test passed"
# echo "→ open in browser: $BASE_URL"

#!/bin/bash
set -e

NAMESPACE="demo"
TIMEOUT=180

echo "→ waiting for pods..."
kubectl wait --for=condition=ready pod -l app=client -n $NAMESPACE --timeout=${TIMEOUT}s
kubectl wait --for=condition=ready pod -l app=server -n $NAMESPACE --timeout=${TIMEOUT}s
echo "✓ pods ready"

MINIKUBE_IP=$(minikube ip)
NODE_PORT=$(kubectl get svc client -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')
BASE_URL="http://${MINIKUBE_IP}:${NODE_PORT}"

echo "→ testing client at $BASE_URL..."
CLIENT_RESPONSE=$(curl -sf $BASE_URL)
[ -z "$CLIENT_RESPONSE" ] && echo "✗ client failed" && exit 1
echo "✓ client ok (${#CLIENT_RESPONSE} bytes)"

echo "→ testing api at $BASE_URL/api/button1..."
BUTTON1=$(curl -sf $BASE_URL/api/button1)
echo "$BUTTON1" | grep -q '"ok":true' || { echo "✗ api failed"; exit 1; }
echo "✓ api ok: $BUTTON1"

echo ""
echo "✓ smoke test passed"
echo "→ open in browser: $BASE_URL"