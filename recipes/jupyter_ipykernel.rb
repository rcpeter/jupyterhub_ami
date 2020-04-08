#
# Cookbook:: jupyterhub-chef
# Recipe:: jupyter_ipykernel

if node['jupyter'].attribute?('kernels')
  node['jupyter']['kernels'].each do |kernel, config|
    if config['install']
      # python2
      if config['python_dist'] == 'python2'
        bash 'jupyter_create_python2_kernel' do
          code <<-EOF
            if ! /bin/jupyter kernelspec list | grep -q "#{kernel}"; then
              #{node['python']['python2']['bin']} -m pip install --upgrade ipykernel
              #{node['python']['python2']['bin']} -m ipykernel install --name "#{kernel}" --display-name "#{config['displayname']}"
            fi
          EOF
        end
      # python3
      elsif config['python_dist'] == 'python3'
        bash 'jupyter_create_python3_kernel' do
          code <<-EOF
            if ! /bin/jupyter kernelspec list | grep -q "#{kernel}"; then
              #{node['python']['python3']['bin']} -m pip install --upgrade ipykernel
              #{node['python']['python3']['bin']} -m ipykernel install --name "#{kernel}" --display-name "#{config['displayname']}"
            fi
          EOF
        end
      # python_env
      elsif config['python_dist'] == 'python_env'
        bash 'jupyter_create_python_virtualenv_kernel' do
          code <<-EOF
            if ! /bin/jupyter kernelspec list | grep -q "#{kernel}"; then
              source #{node['python']['virtualenvs'][config['python_env']]['dest_dir']}/#{config['python_env']}/bin/activate
              python -m pip install --upgrade ipykernel
              python -m ipykernel install --name "#{kernel}" --display-name "#{config['displayname']}"
            fi
          EOF
        end
      # anaconda
      elsif config['python_dist'] == 'anaconda'
        bash 'jupyter_create_anaconda_kernel' do
          code <<-EOF
            if ! /bin/jupyter kernelspec list | grep -q "#{kernel}"; then
              source /etc/profile.d/anaconda.sh
              python -m pip install --upgrade ipykernel
              python -m ipykernel install --name "#{kernel}" --display-name "#{config['displayname']}"
            fi
          EOF
        end
      # anaconda_env
      elsif node['jupyter']['kernels'][kernel]['python_dist'] == 'anaconda_env'
        bash 'jupyter_create_anaconda_virtualenv_kernel' do
          code <<-EOF
            if ! /bin/jupyter kernelspec list | grep -q "#{kernel}"; then
              source /etc/profile.d/anaconda.sh
              source activate #{config['python_env']}
              python -m pip install --upgrade ipykernel
              python -m ipykernel install --name "#{kernel}" --display-name "#{config['displayname']}"
              conda deactivate
            fi
          EOF
        end
      end
    end
  end unless node['jupyter']['kernels'].empty?
end
