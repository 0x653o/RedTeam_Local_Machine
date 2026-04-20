#!/usr/bin/env bash
# =============================================================================
# infra/k8s/cluster-setup.sh
# One-time setup script: k3s + Kata Containers (Firecracker) + RuntimeClass
# Run as root on your dedicated server.
# =============================================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✗]${NC} $*"; exit 1; }

# ---------------------------------------------------------------------------
# 0. Check root
# ---------------------------------------------------------------------------
[[ $EUID -ne 0 ]] && error "Run as root: sudo bash cluster-setup.sh"

# ---------------------------------------------------------------------------
# 1. Install k3s
# ---------------------------------------------------------------------------
info "Installing k3s..."
if command -v k3s &>/dev/null; then
    warn "k3s already installed — skipping"
else
    curl -sfL https://get.k3s.io | sh -
    # Make kubeconfig accessible to current user
    mkdir -p ~/.kube
    cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    chmod 600 ~/.kube/config
    export KUBECONFIG=~/.kube/config
fi

kubectl get nodes || error "k3s not responding — check service status"
info "k3s installed: $(kubectl version --short 2>/dev/null | head -1)"

# ---------------------------------------------------------------------------
# 2. Check hardware virtualization (required for Kata/Firecracker)
# ---------------------------------------------------------------------------
info "Checking hardware virtualization support..."
VT_COUNT=$(grep -c "vmx\|svm" /proc/cpuinfo || true)
if [[ "$VT_COUNT" -eq 0 ]]; then
    warn "Hardware virtualization NOT detected (VT-x / AMD-V)."
    warn "Kata Containers (Firecracker) WILL NOT work."
    warn "Escape challenge machines cannot be safely enabled on this host."
    warn "Skipping Kata install — normal machines will still work."
    KATA_AVAILABLE=false
else
    info "Hardware virtualization detected ($VT_COUNT vCPUs with vmx/svm)."
    KATA_AVAILABLE=true
fi

# ---------------------------------------------------------------------------
# 3. Install Kata Containers + Firecracker (if VT-x available)
# ---------------------------------------------------------------------------
if [[ "$KATA_AVAILABLE" == "true" ]]; then
    info "Installing Kata Containers + Firecracker backend..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/kata-containers/kata-containers/main/utils/kata-manager.sh) install-kata-tools"

    # Register Kata Firecracker as a k3s RuntimeClass
    info "Registering kata-fc RuntimeClass in k3s..."
    kubectl apply -f - <<EOF
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: kata-fc
handler: kata-fc
EOF

    # Verify
    info "Verifying Kata runtime..."
    kubectl run kata-verify \
        --image=busybox:latest \
        --overrides='{"spec":{"runtimeClassName":"kata-fc"}}' \
        --rm -it --restart=Never \
        -- sh -c "uname -r && echo 'Kata OK'" 2>/dev/null || \
        warn "Kata verification pod failed — check kata-containers installation"
fi

# ---------------------------------------------------------------------------
# 4. Create lm-system namespace for portal backend service account
# ---------------------------------------------------------------------------
info "Creating lm-system namespace..."
kubectl create namespace lm-system --dry-run=client -o yaml | kubectl apply -f -

# ---------------------------------------------------------------------------
# 5. Apply portal backend ClusterRole (allows Pod management across namespaces)
# ---------------------------------------------------------------------------
info "Applying portal backend RBAC..."
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: lm-portal-backend
  namespace: lm-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: lm-portal-backend-role
rules:
  - apiGroups: [""]
    resources: ["namespaces", "pods"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: ["networking.k8s.io"]
    resources: ["networkpolicies"]
    verbs: ["get", "list", "create", "update", "delete"]
  - apiGroups: ["node.k8s.io"]
    resources: ["runtimeclasses"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: lm-portal-backend-binding
subjects:
  - kind: ServiceAccount
    name: lm-portal-backend
    namespace: lm-system
roleRef:
  kind: ClusterRole
  name: lm-portal-backend-role
  apiGroup: rbac.authorization.k8s.io
EOF

# ---------------------------------------------------------------------------
# 6. Create lm-secrets (flag seed placeholder)
# ---------------------------------------------------------------------------
if [[ -f ../../.env ]]; then
    source ../../.env
    FLAG_SEED="${FLAG_SEED:-changeme}"
else
    FLAG_SEED="changeme-set-in-env"
fi

kubectl create secret generic lm-secrets \
    --from-literal=flag-seed="$FLAG_SEED" \
    --namespace=lm-system \
    --dry-run=client -o yaml | kubectl apply -f -

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
info "=== Cluster Setup Complete ==="
kubectl get nodes
echo ""
info "k3s:            $(k3s --version | head -1)"
info "Kata available: $KATA_AVAILABLE"
info "lm-system ns:   $(kubectl get ns lm-system -o jsonpath='{.status.phase}')"
echo ""
info "Next step: run ./infra/vpn/setup-ca.sh to initialize OpenVPN CA"
