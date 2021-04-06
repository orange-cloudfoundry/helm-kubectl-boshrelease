def create_do_commands_array (actions)
  cmds= []
  actions.each { |action|
    category= action['type']
    cmd = ""
    case category
    when 'namespace'
      cmd = do_create_namespace(action,ActionProperties.default_per_namespace_max_pods)
    when 'secret'
      cmd = do_create_secret(action)
    when 'basic_auth_secret'
      cmd = do_create_basic_auth(action)
    when 'kubectl'
      cmd = do_create_kubectl(action)
    when 'exec'
      cmd = do_create_exec(action)
    when 'helm_repo'
      cmd = do_add_repo(action,ActionProperties.mirror_enabled,ActionProperties.mirror_url,ActionProperties.mirror_ca_cert)
    when 'helm_chart'
      cmd = do_install_chart(action)
    else
      puts("ERROR !!! unknown type: #{category}")
    end
    puts("#{cmd}")
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
    when 'basic_auth_secret'
      cmd = undo_create_basic_auth(action)
    when 'secret'
      cmd = undo_create_secret(action)
    when 'kubectl'
      cmd = undo_create_kubectl(action)
    when 'helm_repo'
      # nothing to do #
    when 'helm_chart'
      cmd = undo_install_chart(action)
    else
      puts("unknown type: #{category}")
    end

    if cmd.eql?""
    else
      cmds.insert(0,cmd)
    end
  }
  cmds
end


