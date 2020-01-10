#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'
require 'base64'
require_relative 'declare_vars'
require_relative 'kubectl_pv'
require_relative 'create_command_array'

cmd_init ="export HELM_HOME=/var/vcap/store/action/;"
cmd_init =("#{cmd_init} export KUBECONFIG=/var/vcap/jobs/action/config/kubeconfig;")
isOnFail = false
cmds = create_undo_commands_array(actions)
cmds.each{ |cmd|

      result=system("#{cmd_init}#{cmd} > err.txt 2>&1 ")
      if !result
          puts "first try failed: #{cmd}"
          system("cat err.txt")
          isOnFail = true
      end
}
if (isOnFail)
  fail("some uninstall cannot be performed need to delete with option --force")
end