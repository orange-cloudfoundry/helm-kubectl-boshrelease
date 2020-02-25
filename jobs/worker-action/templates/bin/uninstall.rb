#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'
require 'base64'
require_relative 'declare_vars'
require_relative 'kubectl_pv'

if (ActionProperties.create_storageclass.eql? "true")
  storageclass =ActionProperties.storageclass
  cmd = "kubectl delete storageclass #{storageclass} "
  result= system("#{cmd}")
  if !result
    puts "ACTION FAILED: #{cmd}"
  else
    puts "ACTION SUCCESS: #{cmd}"
  end
end
