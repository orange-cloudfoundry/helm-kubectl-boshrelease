#!/bin/bash
source ./set_version.sh
bosh add-blob set_version.sh set_version.sh

HELM_FILE=helm-v${HELM_VERSION}-linux-amd64.tar.gz

wget https://get.helm.sh/${HELM_FILE}
wget https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl

bosh add-blob ${HELM_FILE} helm/helm.tar.gz
bosh add-blob kubectl kubectl/kubectl

rm ${HELM_FILE}
rm kubectl
