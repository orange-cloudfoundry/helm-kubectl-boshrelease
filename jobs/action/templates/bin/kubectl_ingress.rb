#===============================================================
# create command for execute kubectl to design ingress rule
#===============================================================
def do_create_ingress(ingress,ingress_class)
  namespace = ingress['namespace']
  name = ingress['name']
  spec = ingress['definition']
  annotations =ingress['annotations']
  filename="/tmp/ingress_#{name}.yml"

  File.open(filename, 'w+') do |f|
    f.puts("#{spec.to_yaml}")
  end
  input_lines = File.readlines(filename)
  input_lines[0]=""

  File.delete(filename)

  File.open(filename, 'w+') do |f|
    f.puts("apiVersion: extensions/v1beta1")
    f.puts("kind: Ingress")
    f.puts("metadata:")
    f.puts("  name: #{name}")
    f.puts("  namespace: #{namespace}")
    f.puts("  annotations:")
    f.puts("    kubernetes.io/ingress.class: #{ingress_class}")
    if annotations != nil
      annotations.each{ |annotation|
        f.puts("    #{annotation['name']}: #{annotation['value']}")
      }
    end
    input_lines.each { |line|
      f.puts("#{line}")
    }
  end
  "kubectl apply -f #{filename} "
end

#===============================================================
# create command for delete ingress rule
#===============================================================
def undo_create_ingress(ingress)
  namespace = ingress['namespace']
  name = ingress['name']
  unless namespace.nil? || namespace == 0
    return "kubectl delete ingress #{name}"
  end
  "kubectl delete ingress -n #{namespace} #{name}"

end
