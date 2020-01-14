def create_do_commands_array (actions)
  cmds= []
  actions.each { |action|
    category= action['type']
    puts("action type: #{category}")
    cmd = ""
    case category
    when 'namespace'
      cmd = (do_create_namespace(action))
    when 'secret'
      cmd = do_create_secret(action)
    when 'ingress'
      cmd = do_create_ingress(action,ingressClass)
    when 'kubectl'
      cmd = do_create_kubectl(action)
    when 'helm_repo'
      cmd = do_add_repo(action,ActionProperties.mirror_enabled,ActionProperties.mirror_url,ActionProperties.mirror_ca_cert)
    when 'helm_chart'
      cmd = do_install_chart(action)
    else
      puts("unknown type: #{category}")
    end
    cmds.push(cmd)
  }
  cmds
end

def create_undo_commands_array (actions)
  cmds= []
  actions.each { |action|
    category= action['type']
    cmd = ""
    case category
    when 'namespace'
      cmd = undo_create_namespace(action)
    when 'secret'
      cmd = undo_create_secret(action)
    when 'ingress'
      cmd = undo_create_ingress(action)
    when 'pv'
      cmd = undo_create_pv(action)
    when 'kubectl'
      cmd = undo_create_kubectl(action)
    when 'helm_repo'
      # nothing to do
    when 'helm_chart'
      cmd = undo_install_chart(action)
    else
      puts("unknown type: #{category}")
    end
    cmds.insert(0,cmd)
  }
  cmds
end


