#!/bin/sh

#-------------------------

HELM_VERSION=2.14.0
KUBECTL_VERSION=1.14.1

#-------------------------

HELM_FILE=helm-v${HELM_VERSION}-linux-amd64.tar.gz

wget https://storage.googleapis.com/kubernetes-helm/${HELM_FILE}
wget https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl

bosh add-blob ${HELM_FILE} helm/${HELM_VERSION}/helm.tar.gz
bosh add-blob kubectl kubectl/${KUBECTL_VERSION}/kubectl

rm ${HELM_FILE}
rm kubectl
