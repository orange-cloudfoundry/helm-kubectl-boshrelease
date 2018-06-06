#!/usr/bin/env ruby
# encoding: utf-8


cmd = "kubectl apply -f ../config/rbac-config"
system(cmd) or raise "unanle to create rbac config"