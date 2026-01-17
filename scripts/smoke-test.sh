set -e

NAMESPACE="demo"
TIMEOUT=600

echo "→ waiting for pods..."
kubectl wait --for=condition=ready pod -l app=client -n "$NAMESPACE" --timeout="${TIMEOUT}s"
kubectl wait --for=condition=ready pod -l app=server -n "$NAMESPACE" --timeout="${TIMEOUT}s"
kubectl wait --for=condition=ready pod -l app=consumer -n "$NAMESPACE" --timeout="${TIMEOUT}s"
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

# ---------- NEW: consumer health check ----------
echo "→ checking consumer status..."
CONSUMER_LOG=$(kubectl logs deployment/consumer -n "$NAMESPACE" --tail=10 2>&1)
if echo "$CONSUMER_LOG" | grep -q "Consumer is running"; then
  # Extract and display the specific consumer status messages
  CONSUMER_STATUS=$(echo "$CONSUMER_LOG" | grep "Consumer is running" | head -1)
  CONSUMER_CONFIG=$(echo "$CONSUMER_LOG" | grep "Waiting for\|Queue:" | head -1)
  
  echo "✓ consumer ok"
  echo "  $CONSUMER_STATUS"
  if [ -n "$CONSUMER_CONFIG" ]; then
    echo "  $CONSUMER_CONFIG"
  fi
else
  echo "✗ consumer not healthy"
  echo "Consumer logs:"
  echo "$CONSUMER_LOG"
  exit 1
fi
