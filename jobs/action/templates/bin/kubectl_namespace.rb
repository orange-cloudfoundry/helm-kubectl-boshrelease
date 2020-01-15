#===============================================================
# create command for execute kubectl to design namespace
#===============================================================
def do_create_namespace(namespace)
  name = namespace['name']
  annotations = namespace['annotations']
  filename="/tmp/ns_#{name}.yml"

  File.open(filename, 'w+') do |f|
    f.puts("apiVersion: v1")
    f.puts("kind: Namespace")
    f.puts("metadata:")
    f.puts("  labels:")
    f.puts("    name: #{name}")
    f.puts("  name: #{name}")

    if annotations != nil
      annotations.each{ |annotation|
        f.puts("    #{annotation['name']}: #{annotation['value']}")
      }
    end
  end
  "kubectl apply -f #{filename} "
end

#===============================================================
# create command for delete namespace
#===============================================================
def undo_create_namespace(namespace)
  name = namespace['name']
  "kubectl delete ns #{name} "
end
