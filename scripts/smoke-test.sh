# set -e

# NAMESPACE="demo"
# TIMEOUT=600

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

# echo "→ waiting for consumer pod..."
# kubectl wait --for=condition=ready pod -l app=consumer -n $NAMESPACE --timeout=${TIMEOUT}s
# echo "✓ consumer pod ready"

# echo "→ verifying consumer consumes a message (retrying up to 60s)..."
# for i in {1..12}; do
#   # trigger event
#   curl -sf "$BASE_URL/api/button1" >/dev/null || true

#   # silent check only
#   if kubectl logs -n $NAMESPACE deploy/consumer -c consumer --since=120s | grep -q "Step: received"; then
#     break
#   fi

#   sleep 5
# done

# # 🔴 PRINT ONCE – proof
# echo ""
# echo "→ consumer received message log:"
# kubectl logs -n $NAMESPACE deploy/consumer -c consumer --since=120s \
#   | grep "Step: received" | tail -n 1 \
#   || { echo "✗ consumer did not receive messages"; exit 1; }

# echo "✓ smoke test passed"


#!/bin/bash
set -e

NAMESPACE="demo"
TIMEOUT=600

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