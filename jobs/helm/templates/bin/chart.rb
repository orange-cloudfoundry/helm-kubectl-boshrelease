#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'

CHART_YAML= <%= p('charts') %>


CHART_YAML_TEST= <<~YAML
---
- name: mygrafana
  chart: stable/grafana
  namespace: default
  properties:
  - name: service.type
    value: ClusterIP
  - name: service.port
    value: 9000
- name: mygrafana2
  chart: stable/grafana
  properties:
  - name: service.type
    value: ClusterIP
  - name: service.port
    value: 9001
  - name: service.test
    value: 9002
YAML



data = YAML.load(CHART_YAML)



data.each { |chart|
    t= ""
    count=0
    pnamespace = chart['namespace']
    chart['properties'].each{ |property|
     pname = property['name']
     pvalue = property['value']

     if (count==0)
      t= " --set #{pname}=#{pvalue}"
      count=1
     else
       t= "#{t},#{pname}=#{pvalue}"
     end

    }
    if (pnamespace == nil)
        cmd ="helm install --name #{chart['name']} #{chart['chart']} #{t}"
    else
        cmd = "helm install --namespace #{pnamespace} --name #{chart['name']} #{chart['chart']} #{t}"
    end
    system(cmd) or raised "#{cmd} : ACTION FAILED"
}


