#===============================================================
# create command for execute kubectl to design namespace
#===============================================================
def do_create_namespace(namespace)
  name = namespace['name']
  annotations = namespace['annotations']
  labels = namespace['labels']
  filename="/tmp/ns_#{name}.yml"

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
  "kubectl apply -f #{filename} "
end

#===============================================================
# create command for delete namespace
#===============================================================
def undo_create_namespace(namespace)
  name = namespace['name']
  "kubectl delete ns #{name} "
end
