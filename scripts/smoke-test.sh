# # set -e

# # NAMESPACE="demo"
# # TIMEOUT=600

# # echo "→ waiting for pods..."
# # kubectl wait --for=condition=ready pod -l app=client -n $NAMESPACE --timeout=${TIMEOUT}s
# # kubectl wait --for=condition=ready pod -l app=server -n $NAMESPACE --timeout=${TIMEOUT}s
# # echo "✓ pods ready"

# # MINIKUBE_IP=$(minikube ip)
# # NODE_PORT=$(kubectl get svc client -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')
# # BASE_URL="http://${MINIKUBE_IP}:${NODE_PORT}"

# # echo "→ testing client at $BASE_URL..."
# # CLIENT_RESPONSE=$(curl -sf $BASE_URL)
# # [ -z "$CLIENT_RESPONSE" ] && echo "✗ client failed" && exit 1
# # echo "✓ client ok (${#CLIENT_RESPONSE} bytes)"

# # echo "→ testing api at $BASE_URL/api/button1..."
# # BUTTON1=$(curl -sf $BASE_URL/api/button1)
# # echo "$BUTTON1" | grep -q '"ok":true' || { echo "✗ api failed"; exit 1; }
# # echo "✓ api ok: $BUTTON1"

# # echo ""

# # echo "→ waiting for consumer pod..."
# # kubectl wait --for=condition=ready pod -l app=consumer -n $NAMESPACE --timeout=${TIMEOUT}s
# # echo "✓ consumer pod ready"

# # echo "→ verifying consumer consumes a message (retrying up to 60s)..."
# # for i in {1..12}; do
# #   # trigger event
# #   curl -sf "$BASE_URL/api/button1" >/dev/null || true

# #   # silent check only
# #   if kubectl logs -n $NAMESPACE deploy/consumer -c consumer --since=120s | grep -q "Step: received"; then
# #     break
# #   fi

# #   sleep 5
# # done

# # # 🔴 PRINT ONCE – proof
# # echo ""
# # echo "→ consumer received message log:"
# # kubectl logs -n $NAMESPACE deploy/consumer -c consumer --since=120s \
# #   | grep "Step: received" | tail -n 1 \
# #   || { echo "✗ consumer did not receive messages"; exit 1; }

# # echo "✓ smoke test passed"


# #!/bin/bash
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
# echo "✓ smoke test passed"


#!/bin/bash
set -e

NAMESPACE="demo"
TIMEOUT=600

echo "→ waiting for pods..."
kubectl wait --for=condition=ready pod -l app=client -n "$NAMESPACE" --timeout="${TIMEOUT}s"
kubectl wait --for=condition=ready pod -l app=server -n "$NAMESPACE" --timeout="${TIMEOUT}s"
echo "✓ pods ready"

MINIKUBE_IP=$(minikube ip)
NODE_PORT=$(kubectl get svc client -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}')
BASE_URL="http://${MINIKUBE_IP}:${NODE_PORT}"

# ---------- NEW: wait for endpoints + http readiness ----------
echo "→ waiting for client service endpoints..."
for i in {1..60}; do
  EP=$(kubectl get endpoints client -n "$NAMESPACE" -o jsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null || true)
  if [ -n "$EP" ]; then
    echo "✓ endpoints ready ($EP)"
    break
  fi
  sleep 1
  if [ "$i" -eq 60 ]; then
    echo "✗ endpoints not ready for service/client"
    echo "DEBUG:"
    kubectl get svc client -n "$NAMESPACE" -o wide || true
    kubectl get endpoints client -n "$NAMESPACE" -o wide || true
    kubectl get pods -n "$NAMESPACE" -o wide || true
    exit 1
  fi
done

echo "→ waiting for client HTTP to respond at $BASE_URL..."
for i in {1..60}; do
  if curl -sf "$BASE_URL" >/dev/null; then
    echo "✓ client HTTP is responding"
    break
  fi
  sleep 1
  if [ "$i" -eq 60 ]; then
    echo "✗ client not reachable at $BASE_URL"
    echo "DEBUG:"
    kubectl get svc client -n "$NAMESPACE" -o wide || true
    kubectl get endpoints client -n "$NAMESPACE" -o wide || true
    kubectl get pods -n "$NAMESPACE" -o wide || true
    exit 1
  fi
done
# -------------------------------------------------------------

echo "→ testing client at $BASE_URL..."
CLIENT_RESPONSE=$(curl -sf "$BASE_URL")
[ -z "$CLIENT_RESPONSE" ] && echo "✗ client failed" && exit 1
echo "✓ client ok (${#CLIENT_RESPONSE} bytes)"

echo "→ testing api at $BASE_URL/api/button1..."
BUTTON1=$(curl -sf "$BASE_URL/api/button1")
echo "$BUTTON1" | grep -q '"ok":true' || { echo "✗ api failed"; exit 1; }
echo "✓ api ok: $BUTTON1"

echo ""
echo "✓ smoke test passed"
