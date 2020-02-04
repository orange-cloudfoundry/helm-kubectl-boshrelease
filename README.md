# BOSH Release for Helm and Kubectl

## Purpose
The purpose of this bosh release is to offer a bosh deployment for Helm chart and Kubectl product
You can declare in your deployment helm repositories and helm charts, a default storage class and ingress rules. 
This bosh release should be use as an errand to apply charts.
It uses Helm V3.

## Usage

### Upload the last release
To use this bosh release, first upload it to your bosh:

```
bosh target BOSH_HOST
git clone https://github.com/orange-cloudfoundry/helm-kubectl-boshrelease
cd helm-kubectl-boshrelease
bosh upload release releases/helm-kubectl/helm-kubectl-1.yml
```


### Base deployment


``` yaml
#Deployment Identification
name: cfcr-addon

#Features Block

#Releases Block
releases:
- name: helm-kubectl
  version: latest

#Stemcells Block
stemcells:
- alias: default
  os: ubuntu-xenial
  version: latest

#Update Block
update:
  canaries: 1
  max_in_flight: 2
  canary_watch_time: 15000-30000
  update_watch_time: 15000-300000

#Instance Groups Block
instance_groups:
- name: cfcr-helm-addons
  vm_type: small
  stemcell: default
  networks:
  - name: ((network))
  azs: [z1]
  instances: 1
  jobs:
  - name: action
    release: helm-kubectl
    properties:
      kubernetes:
        host: ((kubernetes.host))
        port: ((kubernetes.port))
        cluster_ca_certificate: ((kubernetes.cluster_ca_certificate))
        password: ((kubernetes-password))
        default_storageclass: ((default_storageclass))
      ingress_class: traefik
      proxy:
        https: ((https_proxy))
        http: ((http_proxy))
        noproxy: ((no_proxy))
      repository_mirror:
        enabled: true
        url: https://((helm_mirror_url))
      actions:
      - type: helm_repo
        name: stable
        url: https://kubernetes-charts.storage.googleapis.com/
      - type: helm_repo
        name: incubator
        url: https://kubernetes-charts-incubator.storage.googleapis.com/
```
## add namespace
As helm_V3 doesn't create namespace, you can create namespace by using this kind of operator.
 
example: 
``` yaml
 - type: replace
   path: /instance_groups/name=cfcr-helm-addons/jobs/name=action/properties/actions/-
   value:
     type: namespace
     name: my-namespace    
```
Caution: During bosh delete-deployment the created namespace will be deleted. So be careful do  not create `kube-system` namespace with this kind of operator. 

## add helm repository
Some time the chart need to be loaded from a specific helm repository. You can do that with this operator.
 
``` yaml
- type: replace
  path: /instance_groups/name=cfcr-helm-addons/jobs/name=action/properties/actions/-
  value:
    type: helm_repo
    name: gitlab
    url: https://charts.gitlab.io                          
```

## add helm chart
Helm chart deployment can be customize by properties or by value file  


``` yaml
- type: replace
  path: /instance_groups/name=cfcr-helm-addons/jobs/name=action/properties/actions/-
  value:
    type: helm_chart
    name: gitlab
    chart:  gitlab/gitlab
    namespace: gitlab
    version: ((gitlab-version))
    properties:
    - name: gitlab.unicorn.ingress.tls.secretName
      value: release-gitlab-tls
    - name: unicorn.ingress.enabled
      value: false

    values-file-content:
      global:
        ## GitLab operator is Alpha. Not for production use.
        operator:
          enabled: false
        ## doc/installation/deployment.md#deploy-the-community-edition
        edition: ce

        ## doc/charts/globals.md#gitlab-version
        # gitlabVersion: master

        ## doc/charts/globals.md#application-resource
        application:
          create: false
        ...
                          
```
Caution: During bosh delete-deployment the created instance of chart will be deleted.
## add kubectl cmd

example with an apply deployment
``` yaml
- type: replace
  path: /instance_groups/name=cfcr-helm-addons/jobs/name=action/properties/actions/-
  value:
    type: kubectl
    name: "deploy-k8sdash"
    cmd: "apply"
    options: ""
    content:
      kind: Deployment
      apiVersion: apps/v1
      metadata:
        name: k8dash
        namespace: kube-system
      spec:
        replicas: 1
        selector:
          matchLabels:
            k8s-app: k8dash
        template:
          metadata:
            labels:
              k8s-app: k8dash
          spec:
            containers:
            - name: k8dash
              image: herbrandson/k8dash:latest
              ports:
              - containerPort: 4654
              livenessProbe:
                httpGet:
                  scheme: HTTP
                  path: /
                  port: 4654
                initialDelaySeconds: 30
                timeoutSeconds: 30
            nodeSelector:
              'beta.kubernetes.io/os': linux
```
example with direct apply on content from internet 
``` yaml
- type: replace
  path: /instance_groups/name=cfcr-helm-addons/jobs/name=action/properties/actions/-
  value:
    type: kubectl
    name: "crd-for-cert-manager"
    cmd: "apply"
    options: "-f https://github.com/jetstack/cert-manager/releases/download/v((cert-manager-version))/cert-manager-no-webhook.yaml"
``` 



## add secret

This action will encode in base64 the content of value and create a K8S secret in the namespace.

``` yaml
- type: replace
  path: /instance_groups/name=cfcr-helm-addons/jobs/name=action/properties/actions/-
  value:
    type: secret
    name: cloud-credentials
    namespace: velero
    data:
    - name: cloud
      value: |
        [default]
        aws_access_key_id = backup_remote_s3_access_key_id
        aws_secret_access_key = ((backup_remote_s3_secret_access_key))
```

## add persistent volume

## add ingress



### Development

As a developer of this release, create new releases and upload them:

```
bosh create release --force && bosh -n upload release
```

### Final releases

To share final releases:

```
bosh create release --final
```

By default the version number will be bumped to the next major number. You can specify alternate versions:


```
bosh create release --final --version 2.1
```

After the first release you need to contact [Dmitriy Kalinin](mailto://dkalinin@pivotal.io) to request your project is added to https://bosh.io/releases (as mentioned in README above).
