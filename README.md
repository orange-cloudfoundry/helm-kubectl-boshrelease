# BOSH Release for Helm and Kubectl

## Purpose
The purpose of this bosh release is to offer a bosh deployment for Helm chart and Kubectl product
You can declare in your deployment helm repositories and helm charts, a default storage class and ingress rules. 
This bosh release should be use as an errand to apply charts.

## Usage

To use this bosh release, first upload it to your bosh:

```
bosh target BOSH_HOST
git clone https://github.com/orange-cloudfoundry/helm-kubectl-boshrelease
cd helm-kubectl-boshrelease
bosh upload release releases/helm-kubectl/helm-kubectl-1.yml
```
## Example of use
``` yaml
---
#Instance Groups Block                                                                               
instance_groups:                                                                                     
- name: cfcr-empty                                                                                   
  vm_type: small                                                                                     
  stemcell: trusty                                                                                   
  networks:                                                                                          
  - name: tf-net-kubo                                                                                
  azs: [z1,z2,z3]                                                                                    
  instances: 1                                                                                       
  jobs:                                                                                              
  - name: shell                                                                                      
    release: shell                                                                                   
                                                                                                     
- name: cfcr-addon                                                                                   
  vm_type: small                                                                                     
  stemcell: trusty                                                                                   
  persistent_disk_type: default                                                                      
  networks:                                                                                          
  - name: tf-net-kubo                                                                                
  azs: [z1,z2,z3]                                                                                    
  lifecycle: errand                                                                                  
  instances: 1                                                                                       
  jobs:                                                                                              
  - name: helm                                                                                       
    release: helm-kubectl                                                                            
    properties:                                                                                      
      kubernetes:                                                                                    
        host: ((kubernetes.host))                                                                    
        port: ((kubernetes.port))                                                                    
        cluster_ca_certificate: ((kubernetes.cluster_ca_certificate))                                
        password: ((kubernetes-password))                                                            
        default_storageclass: tf-cinder-storage-class                                                
                                                                                                     
      repositories:                                                                                  
      - name: stable                                                                                 
        url: https://kubernetes-charts.storage.googleapis.com/                                       
      - name: incubator                                                                              
        url : https://kubernetes-charts-incubator.storage.googleapis.com/ 
        
      charts:                                                                                        
      - name: nginx-ingress                                                                          
        chart: stable/nginx-ingress                                                                  
        version: 0.23.1                                                                              
        properties:                                                                                  
        - name: rbac.create                                                                          
          value: true                                                                                
        - name: controller.service.type                                                              
          value: NodePort                                                                            
        - name: controller.service.nodePorts.https                                                   
          value: 30725                                                                               
        - name: controller.service.nodePorts.http                                                    
          value: 30726                                                                               
        - name: revisionHistoryLimit                                                                 
          value: 5                                                                                   
        - name: controller.extraArgs.enable-ssl-passthrough                                          
          value: ""                                                                                  
                                                                                                     
                                                                                                     
      ingress: []                                                                                    
                                                                                                     
```

Charts can also use values instead of properties:
```
     charts:                                                                                        
      - name: nginx-ingress                                                                          
        chart: stable/nginx-ingress                                                                  
        version: 0.23.1                                                                              
        values:                                                                                  
          rbac:
            create: true                                                                                
          controller:
            service: 
              type: NodePort                                                                            
              nodePorts:
                https: 30725                                                                               
                http: 30726 
            extraArgs:
              enable-ssl-passthrough: ""
          revisionHistoryLimit: 5                                                                 
                          
```

To have debug information during helm deployment use :
debug: true

```
     charts:                                                                                        
      - name: nginx-ingress                                                                          
        chart: stable/nginx-ingress                                                                  
        version: 0.23.1  
        debug: true
        values:                                                                                  
          rbac:
            create: true                                                                                
          controller:
            service: 
              type: NodePort                                                                            
              nodePorts:
                https: 30725                                                                               
                http: 30726 
            extraArgs:
              enable-ssl-passthrough: ""
          revisionHistoryLimit: 5                                                                 
                          
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
