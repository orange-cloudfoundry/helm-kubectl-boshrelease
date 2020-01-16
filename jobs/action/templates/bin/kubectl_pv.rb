#===============================================================
# create command for execute kubectl to design pv
#===============================================================
def do_create_pv(pv,storageclass)
  name = pv['name']
  storage = pv['storage']
  path = pv['path']
  label = pv['label']
  node = pv['node']
  filename= "/tmp/pv_#{name}.yml"
  File.open(filename, 'w+') do |f|
    f.puts("apiVersion: v1")
    f.puts("kind: PersistentVolume")
    f.puts("metadata:")
    f.puts("  name: #{name}")
    f.puts("spec: ")
    f.puts("  capacity:")
    f.puts("  storage: #{storage}")
    f.puts("accessModes:")
    f.puts("- ReadWriteOnce")
    f.puts("persistentVolumeReclaimPolicy: Retain")
    f.puts("storageClassName: #{storageclass}")
    f.puts("local:")
    f.puts("  path: #{path}")
    f.puts("nodeAffinity:")
    f.puts("  required:")
    f.puts("    nodeSelectorTerms:")
    f.puts("    - matchExpressions:")
    f.puts("      - key: #{label}")
    f.puts("        operator: In")
    f.puts("        values:")
    f.puts("        - #{node}")
  end
  return "kubectl apply -f #{filename} "
end

#===============================================================
# create command for delete pv
#===============================================================
def undo_create_pv(pv)
  name = pv['name']
  return "kubectl delete pv  #{name}"
end





