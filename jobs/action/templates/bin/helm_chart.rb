require 'yaml'
#===============================================================
# create command for install or update helm chart
#===============================================================
def do_install_chart(chart)
  t= ""
  namespace = chart['namespace']
  properties = chart['properties']
  version = chart['version']
  command = chart['cmd']
  options = chart['options']
  values = chart['values_file_content']
  files = chart['files']
  name = chart['name']
  filename= "/var/vcap/data/action/chart_#{name}.yml"

  if properties != nil
    properties.each{ |property|
      if property != nil
         t= "#{t} --set #{property['name']}=#{property['value']}"
      end
    }
  end

  if command.nil?
    command = "upgrade"
  end
  if options.nil?
    options = "--install --atomic --cleanup-on-fail"
  end

  cmd = "helm #{command} #{options}"

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
  command = chart['cmd']
  if (command.nil? || ("install".eql? command) || ("udate".eql? command))
    cmd = "helm uninstall "
    unless namespace.nil? || namespace == 0
      cmd = "#{cmd} --namespace #{namespace}"
    end
    "#{cmd} #{name}"
  end
  end
end