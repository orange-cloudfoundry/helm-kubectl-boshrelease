def create_do_commands_array (actions)
  var cmds= []
  actions.each { |action|
    category= action['type']
    object= action['type']
    cmd = ""
    case category
    when 'namespace'
      cmd.push(do_create_namespace(object))
    when 'secret'
      cmd= do_create_secret(object)
    when 'ingress'
      cmd = do_create_ingress(object,ingressClass)
    when 'kubectl'
      cmd =do_create_kubectl(object)
    when 'helm_repo'
      cmd = do_add_repo(object,mirror_enabled,mirror_url,mirro_ca_cert)
    when 'helm_chart'
      cmd = do_install_chart(object)
    end
    cmds.push(cmd)
  }
  cmds
end

def create_undo_commands_array (actions)
  var cmds= []
  actions.each { |action|
    category= action['type']
    object= action['type']
    cmd = ""
    case category
    when 'namespace'
      cmd.push(undo_create_namespace(object))
    when 'secret'
      cmd= undo_create_secret(object)
    when 'ingress'
      cmd = undo_create_ingress(object,ingressClass)
    when 'kubectl'
      cmd = undo_create_kubectl(object)
    when 'helm_repo'
      # nothing to do
    when 'helm_chart'
      cmd = undo_install_chart(object)
    end
    cmds.insert(0,cmd)
  }
  cmds
end
