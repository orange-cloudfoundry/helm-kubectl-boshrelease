#===============================================================
# create command for execute kubectl
#===============================================================
def do_create_kubectl(apply)
  name = apply['name']
  namespace = apply['namespace']
  options = apply['options']
  cmd = apply['cmd']
  content = apply['content']

  kubectl_cmd ="kubectl #{cmd} "
  unless namespace.nil? || namespace == 0
    kubectl_cmd = "#{kubectl_cmd} --namespace #{namespace} "
  end
  unless options .nil? || options  == 0
    kubectl_cmd = "#{kubectl_cmd} #{apply['options']}"
  end
  unless content .nil? || content  == 0
    File.open("#{name}.yml", 'w') {|f| f.write content .to_yaml }
    kubectl_cmd = "#{kubectl_cmd} -f #{name}.yml"
  end
  kubectl_cmd
end

#===============================================================
# create command for execute kubectl
#===============================================================
def undo_create_kubectl(apply)
  name = apply['name']
  namespace = apply['namespace']
  cmd = apply['cmd']
  content = apply['content']

  kubectl_cmd = nil
  if cmd.equal?'apply'
    kubectl_cmd ="kubectl delete "
    unless namespace.nil? || namespace == 0
      kubectl_cmd = "#{kubectl_cmd} --namespace #{namespace} "
    end
    unless content .nil? || content  == 0
      File.open("#{name}.yml", 'w') {|f| f.write content .to_yaml }
      kubectl_cmd = "#{kubectl_cmd} -f #{name}.yml"
    end

  end
  kubectl_cmd
end