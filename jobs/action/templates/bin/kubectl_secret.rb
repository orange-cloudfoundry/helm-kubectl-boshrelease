
#===============================================================
# create command for execute kubectl to design secret
#===============================================================
def do_create_secret(secret)
  namespace = secret['namespace']
  name = secret['name']
  spec = secret['data']
  annotations =secret['annotations']
  type= secret['type']
  labels= secret['labels']
  filename="/tmp/secret_#{name}.yml"


  File.open(filename, 'w+') do |f|
    f.puts("apiVersion: v1")
    f.puts("kind: Secret")
    f.puts("metadata:")
    f.puts("  name: #{name}")
    f.puts("  namespace: #{namespace}")
    f.puts("  annotations:")
    if (annotations != nil)
      annotations.each{ |annotation|
        f.puts("    #{annotation['name']}: #{annotation['value']}")
      }
    end
    f.puts("  labels:")
    if (labels != nil)
      labels.each{ |label|
        f.puts("    #{label['name']}: #{label['value']}")
      }
    end
    if (spec != nil)
      f.puts("data:")
      spec.each { |spec|
        b=  Base64.encode64(spec['value'])
        b.delete!("\n")
        f.puts("  #{spec['name']}: #{b}")
      }
      f.puts(type.to_s)
    end
  end
  return "kubectl apply -f #{filename} "
end


#===============================================================
# create command for delete secret
#===============================================================
def undo_create_secret(secret)
    namespace = secret['namespace']
    name = secret['name']
    unless namespace.nil? || namespace == 0
      return "kubectl delete secret #{name}"
    end
    return "kubectl delete secret -n #{namespace} #{name}"

end