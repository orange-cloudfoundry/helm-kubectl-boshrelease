#===============================================================
# create command for execute kubectl to design namespace
#===============================================================
def do_create_namespace(namespace, default_per_namespace_max_pods)
  name = namespace['name']
  annotations = namespace['annotations']
  labels = namespace['labels']
  max_pods = namespace['max_pods']
  filename=."/tmp/ns_#{name}.yml"
  filenameresourcequota="/tmp/ns_#{name}_quota.yml"
  File.open(filename, 'w+') do |f|
    f.puts("apiVersion: v1")
    f.puts("kind: Namespace")
    f.puts("metadata:")
    f.puts("  name: #{name}")
    f.puts("  labels:")
    f.puts("    name: #{name}")
    if labels != nil
      labels.each{ |label|
        f.puts("    #{label['name']}: #{label['value']}")
      }
    end

    if annotations != nil
      f.puts("  anotations: ")
      annotations.each{ |annotation|
        f.puts("    #{annotation['name']}: #{annotation['value']}")
      }
    end
  end
  cmd = "kubectl apply -f #{filename} "

  if max_pods ==nil
    max_pods = default_per_namespace_max_pods
  end
  if max_pods != "-1"
    File.open(filenameresourcequota, 'w+') do |f|
      f.puts("apiVersion: v1")
      f.puts("kind: ResourceQuota")
      f.puts("metadata:")
      f.puts("  name: quota-#{name}")
      f.puts("  namespace: #{name}")
      f.puts("spec:")
      f.puts("  hard:")
      f.puts("    pod: max_pod")
    cmd ="kubectl apply -f #{filename} ;kubectl apply -f #{filenameresourcequota}"
    end
  end
  cmd

#===============================================================
# create command for delete namespace
#===============================================================
def undo_create_namespace(namespace)
  name = namespace['name']
  "kubectl delete ns #{name} "
end
