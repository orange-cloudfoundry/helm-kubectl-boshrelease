#===============================================================
# create command for execute kubectl to design namespace
#===============================================================
def do_create_namespace(namespace)
  cmd=""
  name = namespace['name']
  annotations = namespace['annotations']
  filename="/tmp/ns_#{name}.yml"

  File.open(filename, 'w+') do |f|
    f.puts("kind: Namespace")
    f.puts("metadata:")
    f.puts("  labels:")
    f.puts("    name: #{namespace}")
    f.puts("  name: #{namespace}")

    if (annotations != nil)
      annotations.each{ |annotation|
        f.puts("    #{annotation['name']}: #{annotation['value']}")
      }
    end
  end
  cmd = "kubectl apply -f #{filename} "
  cmd
end

#===============================================================
# create command for delete namespace
#===============================================================
def undo_create_namespace(ingress)
  name = namespace['name']
  return "kubectl delete ns #{name} "
end
