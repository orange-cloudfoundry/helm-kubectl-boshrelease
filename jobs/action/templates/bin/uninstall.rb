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
require_relative 'kubectl_secret'
require_relative 'create_command_array'

cmd_init ="export HELM_HOME=/var/vcap/store/action/;"
isOnFail = false
puts "============================="
puts "create list of undo commands"
puts "============================="

cmds = create_undo_commands_array(ActionProperties.actions)
puts "============================="
puts "execute list of commands"
puts "============================="

cmds.each{ |cmd|
      puts "#{cmd}"
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