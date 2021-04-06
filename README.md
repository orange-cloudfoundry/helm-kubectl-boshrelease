# BOSH Release for Helm and Kubectl

## Purpose
The purpose of this bosh release is to offer a bosh deployment for Helm chart and Kubectl product
You can declare in your deployment helm repositories and helm charts, a default storage class and ingress rules. 
This bosh release should be use as an errand to apply charts.
It uses Helm V3.

## Usage
see web site: https://orange-cloudfoundry.github.io/helm-kubectl-boshrelease/
These bosh release is composed by 1 jobs

- action
  - it creates namespace
  - it applies kubectl command
  - it adds helm repository
  - it creates helm chart instance
  - it creates secret
  - it creates basic auth secret
  - it can execute any shell

During undeploy of the bosh release every thing created by action will be deleted.
 
### Upload the last release
To use this bosh release, first upload it to your bosh:
Note: _change the index the helm-kubectl-[index].yml to the last version of the bosh release_

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
### Action job
Action job provide an array of action. They are apply during bosh errand usage or on each deploy in case of `run_on_each_deploy=true`
How it works internally: Each action will be converted into kubectl or helm command 
## add namespace
As helm_V3 doesn't create namespace, you can create namespace by using this kind of operator.
 
basic example: 
``` yaml
 - type: replace
   path: /instance_groups/name=cfcr-helm-addons/jobs/name=action/properties/actions/-
   value:
     type: namespace
     name: my-namespace    
```

example with annotations and labels:

``` yaml
 - type: replace
   path: /instance_groups/name=cfcr-helm-addons/jobs/name=action/properties/actions/-
   value:
     type: namespace
     name: my-namespace
     annotations:
     - name: myannotation
       value: hello
     labels:
     - name: mylabel
       value: hello
         
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

    values_file_content:
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
By default the helm type will perform

Caution: During bosh delete-deployment the created instance of chart will be deleted.
## add kubectl cmd

example of use with an apply deployment
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

example of use with direct apply on content from internet :

``` yaml
- type: replace
  path: /instance_groups/name=cfcr-helm-addons/jobs/name=action/properties/actions/-
  value:
    type: kubectl
    name: "crd-for-cert-manager"
    cmd: "apply"
    options: "-f https://github.com/jetstack/cert-manager/releases/download/v((cert-manager-version))/cert-manager-no-webhook.yaml"
``` 

example of use to produce a config map with very large content:

```  yaml
- type: replace
  path: /instance_groups/name=cfcr-helm-addons/jobs/name=kubectl/properties/commands/-
  value:
    name: "cm-grafana-k8s-master-node-exporter-dashboard"
    cmd: "replace"
    options: " --force --save-config=false "
    apply:
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: dash-k8s-all-node-exporter
        namespace: monitoring
        labels:
          grafana_dashboard: '1'
      data:
        grafana_k8d_all_node_exporter_dashboard.json: |
          {
            "annotations": {
              "list": [
                {
                  "builtIn": 1,
                  ....
```                   
                  
## add secret

This action will encode in base64 the content of value and create a K8S secret in the namespace.
By default the type of the secret is generic but it can be override by `secret_type`  

example of use:
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
## add secret for basic auth

This action will encode in base64 the content of value and create a K8S secret in the namespace.

example of use:
``` yaml
- type: replace
  path: /instance_groups/name=cfcr-helm-addons/jobs/name=action/properties/actions/-
  value:
    type: basic_auth_secret
    name: mybasicauth
    namespace: traefik
    user: admin
    password: ((mypassword))
```

## add exec action
This action let user to use kubelet or helm or kustomise in shell
to perform any shell script.

example:

``` 
- type: replace
  path: /instance_groups/name=k8s-helm-addons/jobs/name=action/properties/actions/-
  value:
    type: exec
    cmd: |
      cat << EOF > /tmp/coredns.yml
      ((coredns_clusterrole))
      ---
      ((coredns_clusterrolebinding))
      ---
      ((coredns_configmap))
      ---
      ((coredns_deployment))
      ---
      ((coredns_service))
      EOF
      kubectl apply -f  /tmp/coredns.yml
```





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
