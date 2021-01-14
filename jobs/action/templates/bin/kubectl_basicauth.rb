
#===============================================================
# create command for execute kubectl to design secret
#===============================================================
def do_create_basic_auth(secret)
  namespace = secret['namespace']
  name = secret['name']
  user = secret['user']
  password = secret['password']

  annotations =secret['annotations']
  labels= secret['labels']
  filename="/tmp/secret_#{name}.yml"


  File.open(filename, 'w+') do |f|
    f.puts("apiVersion: v1")
    f.puts("kind: Secret")
    f.puts("metadata:")
    f.puts("  name: #{name}")
    f.puts("  namespace: #{namespace}")
    f.puts("  annotations:")
    if annotations != nil
      annotations.each{ |annotation|
        f.puts("    #{annotation['name']}: #{annotation['value']}")
      }
    end
    if labels != nil
      f.puts("  labels:")
      labels.each{ |label|
        f.puts("    #{label['name']}: #{label['value']}")
      }
    end

    f.puts("data:")
    encryptedpassword=BCrypt::Password.create("#{password}")
    chaine="#{user}:#{encryptedpassword}"
    b=  Base64.encode64(chaine)
    b.delete!("\n")
    f.puts("  users: #{b}")

  end
  "kubectl apply -f #{filename} "
end


#===============================================================
# create command for delete secret
#===============================================================
def undo_create_basic_auth(secret)
    namespace = secret['namespace']
    name = secret['name']
    unless namespace.nil? || namespace == 0
      return "kubectl delete secret #{name} --ignore-not-found=true "
    end
    "kubectl delete secret -n #{namespace} #{name} --ignore-not-found=true "

end