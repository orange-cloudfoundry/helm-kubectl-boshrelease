#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'
require 'base64'
require 'declare_vars'
require 'helm_chart'
require 'helm_repository'
require 'kubectl_command'
require 'kubectl_ingress'
require 'kubectl_namespace'
require 'kubectl_secret'
require 'create_command_array'

cmd_init ="export HELM_HOME=/var/vcap/store/action/;"
cmd_init =("#{cmd_init} export KUBECONFIG=/var/vcap/jobs/action/config/kubeconfig;")

max_retries = 3
sleep_duration = 5

fail_cmd = []
is_on_fail=false
cmds = create_do_commands_array(ActionProperties.actions)
cmds.each{ |cmd|
    # Begin the retryable operation
    retry_count = 0
    begin
      result=system("#{cmd_init}#{cmd} > err.txt 2>&1 ")
      if !result
          puts "first try failed: #{cmd}"
          system("cat err.txt")
          while !result && retry_count < max_retries
            retry_count += 1
            sleep sleep_duration
            puts "retry #{retry_count}"
            result=system("#{cmd_init}#{cmd} > /dev/null 2>&1")
          end
          if !result
            fail_cmd.push("#{cmd}")
            is_on_fail=true
            puts "ACTION delayed after all others: #{cmd}"
          end
      else
         puts "ACTION SUCCESS: #{cmd}"
      end
    end

}
if is_on_fail
  puts "============================="
  puts " Retry unsuccessful actions"
  puts "============================="
  puts ""

  is_on_fail=false
  fail_cmd.each { |cmd|
          result=system("#{cmd_init}#{cmd} > /dev/null")
          if !result
            puts "ACTION FAILED: #{cmd}"
            is_on_fail=true
          end
          if result
             puts "ACTION SUCCESS: #{cmd}"
          end
  }
  if (is_on_fail)
      fail("some action cannot be performed")
  end
 end
puts "============================="
puts " actions done"
