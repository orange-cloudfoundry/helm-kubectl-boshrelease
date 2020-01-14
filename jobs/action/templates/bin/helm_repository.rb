#===============================================================
# create command for add helm repository
#===============================================================
def do_add_repo(repository,mirror_enabled,mirror_url,mirror_ca_cert)
  name = repository['name']
  url = repository['url']
  if mirror_enabled
    cmd = "helm repo add  #{name} #{mirror_url} "
  else
    if mirror_ca_cert.eql? nil
      cmd = "helm repo add  #{name} #{url} "
    else
      cmd = "helm repo add  --ca-file=/var/vcap/store/action/config/mirror_ca_cert.pem #{name} #{url} "
    end
  end
  cmd
end