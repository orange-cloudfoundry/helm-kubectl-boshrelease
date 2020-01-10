#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'
require 'base64'
require_relative 'declare_vars'
require_relative 'helm_chart'
require_relative 'helm_repository'
require_relative 'kubectl_command'
require_relative 'kubectl_ingress'
require_relative 'kubectl_namespace'
require_relative 'kubelet_secret'
require_relative 'create_command_array'

cmd_init ="export HELM_HOME=/var/vcap/store/action/;"
cmd_init =("#{cmd_init} export KUBECONFIG=/var/vcap/jobs/action/config/kubeconfig;")

max_retries = 3
sleep_duration = 5

failCmd = []
isOnFail=false
cmds = create_do_commands_array(actions)
cmds.each{ |cmd|
    # Begin the retryable operation
    retry_count = 0
    begin
      result=system("#{cmd_init}#{cmd} > err.txt 2>&1 ")
      if !result
          puts "first try failed: #{cmd}"
          system("cat err.txt")
      end
      while !result && retry_count < max_retries
        retry_count += 1
        sleep sleep_duration
        puts "retry #{retry_count}"
        result=system("#{cmd_init}#{cmd} > /dev/null 2>&1")
      end
      if !result
        failCmd.push("#{cmd}")
        isOnFail=true
        puts "ACTION delayed after all others: #{cmd}"
      else
         puts "ACTION SUCCESS: #{cmd}"
      end
    end

}
if isOnFail
  puts "============================="
  puts " Retry unsuccessful actions"
  puts "============================="
  puts ""

  isOnFail=false
  failCmd.each { |cmd|
          result=system("#{cmd_init}#{cmd} > /dev/null")
          if !result
            puts "ACTION FAILED: #{cmd}"
            isOnFail=true
          end
          if result
             puts "ACTION SUCCESS: #{cmd}"
          end
  }
  if (isOnFail)
      fail("some action cannot be performed")
  end
 end
puts "============================="
puts " actions done"