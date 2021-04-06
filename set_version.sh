export HELM_VERSION=3.5.3
export KUBECTL_VERSION=1.19.9 # Warning ensure kubectl version is never greater than our k8s version
export KUSTOMIZE_VERSION=4.0.5

echo "helm version:"$HELM_VERSION
echo "kubectl version:"$KUBECTL_VERSION
