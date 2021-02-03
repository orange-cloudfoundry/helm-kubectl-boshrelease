#!/bin/bash
source ./set_version.sh
bosh add-blob set_version.sh set_version.sh

HELM_FILE=helm-v${HELM_VERSION}-linux-amd64.tar.gz
KUSTOMIZE_FILE=kustomize_v${KUSTOMIZE_VERSION}_linux_arm64.tar.gz

wget https://get.helm.sh/${HELM_FILE}
wget https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz



bosh add-blob jq-linux64 jq/jq-linux64
bosh add-blob ${HELM_FILE} helm/helm.tar.gz
bosh add-blob kubectl kubectl/kubectl
bosh add-blob ${KUSTOMIZE} kustomize/kustomize.tar.gz

rm ${HELM_FILE}
rm kubectl
rm jq-linux64
