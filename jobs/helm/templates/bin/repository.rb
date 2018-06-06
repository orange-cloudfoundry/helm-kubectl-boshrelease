#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'
REPOSITORY_YAML = <%= p('repositories') %>



REPOSITORY_YAML_TEST= <<~YAML
---
- name: stable
  url: 'https://kubernetes-charts.storage.googleapis.com/'
- name: 'incubator'
  url: 'https://kubernetes-charts-incubator.storage.googleapis.com'
YAML

data = YAML.load(REPOSITORY_YAML)



data.each { |repository|
     pname = repository['name']
     purl = repository['url']
     cmd = "helm repo add  #{pname} #{purl} "

     system(cmd) or raised "#{cmd} : ACTION FAILED"
   end
}

