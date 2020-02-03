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

## add kubectl cmd

## add secret

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
