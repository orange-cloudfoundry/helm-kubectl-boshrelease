#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'
require 'base64'
require 'json'

require 'declare_vars'

require 'kubectl_pv'

cmd_init ="export HELM_HOME=/var/vcap/store/worker-action/;"
cmd_init =("#{cmd_init} export KUBECONFIG=/var/vcap/jobs/worker-action/config/kubeconfig;")

def do_shell_pv(pv)

  path = pv['path']
  node = pv['node']
  json = JSON.parse(open("/var/vcap/bosh/spec.json").read)
  current_deployment=json['deployment']
  current_name=json['name']
  current_index=json['index']

  current_node= "#{current_deployment}-#{current_name}-#{current_index}"
  if current_node.eql? node
    return "mkdir -p #{path};  chcon -Rt svirt_sandbox_file_t #{path};  chmod 777 #{path};"
  end
end

def create_do_pv_array (actions)
  cmds= []
  actions.each { |action|
    category= action['type']
    object= action['object']
    cmd = ""
    case category
    when 'pv'
      cmd = do_shell_pv(object)
    end
    cmds.push(cmd)
  }
  cmds
end


if (ActionProperties.create_storageclass)
  storageclass =ActionProperties.storageclass
  filename= "/tmp/storageclass_#{storageclass}.yml"
  File.open(filename, 'w+') do |f|
    f.puts("apiVersion: storage.k8s.io/v1")
    f.puts("kind: StorageClass")
    f.puts("metadata:")
    f.puts("  name: #{storageclass}")
    f.puts("provisioner: kubernetes.io/no-provisioner")
    f.puts("volumeBindingMode: WaitForFirstConsumer")
    var cmd = "kubectl apply -f #{filename} "
    result= system("#{cmd_init}#{cmd} > err.txt 2>&1 ")
  end
end

cmds = create_do_pv_array(ActionProperties.actions)
cmds.each{ |cmd|
  # Begin the retryable operation
  begin
    result=system("#{cmd_init}#{cmd} > err.txt 2>&1 ")

    if !result
      puts "ACTION FAILED: #{cmd}"
    else
      puts "ACTION SUCCESS: #{cmd}"
    end
  end
}


