
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