require 'yaml'
#===============================================================
# create command for install or update helm chart
#===============================================================
def do_install_chart(chart)
  t= ""
  namespace = chart['namespace']
  properties = chart['properties']
  version = chart['version']
  debug = chart['debug']
  values = chart['values']
  files = chart['files']
  name = chart['name']
  filename= "chart_#{name}.yml"

  if properties != nil
    properties.each{ |property|
      if property != nil
        name = property['name']
        value = property['value']
        t= "#{t} --set #{name}=#{value}"
      end
    }
  end

  var cmd = "helm upgrade --install "

  unless debug.nil? || debug == 0
    cmd = "#{cmd} --debug"
  end

  unless version.nil? || version == 0
    cmd = "#{cmd} --version=#{version}"
  end

  unless namespace.nil? || namespace == 0
    cmd = "#{cmd} --namespace #{namespace}"
  end

  cmd ="#{cmd} #{name} #{chart['chart']} #{t}"

  unless values .nil? || values  == 0
    File.open("#{filename}", 'w') {|f| f.write values .to_yaml }
    cmd = "#{cmd} -f #{filename}"
  end
  unless files .nil? || files == 0
    files.each {|file|
      cmd = "#{cmd} -f #{file['url']}"
    }
  end
  cmd
end

#===============================================================
# create command for uninstall helm chart
#===============================================================
def undo_install_chart(chart)
  namespace = chart['namespace']
  name = chart['name']

  var cmd = "helm delete "
  unless namespace.nil? || namespace == 0
    cmd = "#{cmd} --namespace #{namespace}"
  end
  cmd = "#{cmd} #{name}"
  cmd
end