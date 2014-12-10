#
# Cookbook Name:: opsworks-lineman-rails
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
Dir.mkdir "#{node['working_dir']}"

node[:deploy].each do |application, deploy|

  # Handle ssh key for git private repo
  ruby_block "write_key" do
    block do
      f = ::File.open("#{node['working_dir']}/id_deploy", "w")
      f.print('-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAsHvfywq2YUQjfRyphRH280yLeR3ZNqhZsrm4Nl7+QxVmp4wn\nVc9IH2A9mm9azTPj2N9CUP+F6qWxrIzIJqLZhDvtWo+fpzX5Bb2d+vZW8b1ybsIj\n9d6d4D426hg9E4AwfCh/lFAYLqMJkUzD2RySQCNbieE19veHZmHlq7HGvlj5HbjK\n/F6RTIT4Xp615Q0QN/d9eH0oUyTIyovIXSyrKdGiTwCF/VMTpzn+4H3iUDKtUZ85\n6MRMRwxekbghoUbJqZjDSrUbzesVe/COxlm5vvBTBnChyDclw+xb07VBqPl8Ctx2\nKQcTParuRmU7YFsMSF+6qaciAW63QRBi3+kViwIDAQABAoIBAQCB2IINRzJsWc+q\ni14F8/O3igfL8rQPzMlB//aSuk1kWeiPOUTvk3RC8XIhn/A0rgrjU0/dfEKxI3uX\nsnTISGS1L8owKR+TzNgM6zfCn1/UuEfrSZdfnIyXoe6RSYgWQuhpUPqcylkgZv/x\nEYO+x5Cq89izlyk3LWNHZpuuOTw6as7x/nC6zGSjUqEYAszCDxjCqAkIpbJMkRbe\n6q9sXdncoQjOxJIrQ9VFANEC+pkvVqC+ZabPISZ4kA5CciyFTB3d111vRolV4jGF\ntHz7FAZMOBmDvDmoqLJEwbB7tqDNZI1NhDtpncJJ/HX4HRW7Gk8ySaPZKmHn8lAu\nq65QeYohAoGBANmgVyPDPzpQ7nnh2hYQJc2quI5O+7KwMsLzbqgOnuFiGvb09VpE\nljgJr9kFQeVsXYbg5DEof2GClpG164yBpMwrhw7mcHj6OlAu5XPfHLAoTavf2CSe\netdKicHloSchmmn8ifd2pclf5dD3tTpUSPbkU0pgCBT8btfzxRwEH+LTAoGBAM+a\nXMk/qEynDDfyF39IFRW2HKuPvy3zM+yBMROR234kdfwbJK6S1HL/gUKaAd9L9UKI\nA8ZUHCetI6bPX47O81I/w6RHtGRTFRuF8pKmVUsU6GK59bNob4JQ+LqVuimmO2ON\nV66xZZxaCJsEG82nJGNelhWyh7+RHomjQv06vJ9pAoGAWw8qJv6lUCNZBYqpFB5B\nkyLiAjmuO4BaXRQ6svsbI7dHDRpGJzUXne7/s1Dt169WGv+yu5b0Zbqcge+a1bnR\nWNTFuEhXu2cIS1C0FZ2/hT338fjBmeDuCXNY3NbWbWc0EzDmEbOFfxMvOBbNr9Bg\nj13ONAqmlxFg199aFHTtWp0CgYEAg5peIXGKNfVbaIe+X4CJZTcJ27QHRJC8pLuN\nKdO3qbJhXMy0JzqLFM9l2Juafjw/oMpqYiplor0+MXuaHwSP+N7VHeoar9J/OfBi\nwpZQ0YTSf+tUl0OoFJtR4a4S0l4/na83G1X3jPMCK4qiOW8wQRHv4JdJOKY9DpGB\nYNgARKkCgYAwcHAxXVXtFsCXiiXc2E+b6goiP4V3abjuPigCvuSpNI1AULhFDBzS\nZTJp8+5fLuQdNv9eUPm1T1VrFtQFgu3H5rgi5JdBvk0GhhSCsx1qkCpX8x2HJxWc\ndBl9NSR4M9ol+WPuWMEM/n5x5sUeHh1ypi4HevY+C2usu3sdHn/zwg==\n-----END RSA PRIVATE KEY-----\n')
      f.close
    end
    not_if do ::File.exists?("#{node['working_dir']}/id_deploy"); end
  end

  file "#{node['working_dir']}/id_deploy" do
    mode '0600'
  end

  template "#{node['working_dir']}/git-ssh-wrapper" do
    source "git-ssh-wrapper.erb"
    mode "0755"
    variables("deploy_dir" => node['deploy_dir'])
  end

  deploy_revision node['working_dir'] do
    scm_provider Chef::Provider::Git 
    repo node['deploy_repo']
    revision node['deploy_branch']
    git_ssh_wrapper "#{node['working_dir']}/git-ssh-wrapper" # For private Git repos 
    enable_submodules false
    shallow_clone false
    symlink_before_migrate({}) # Symlinks to add before running db migrations
    purge_before_symlink [] # Directories to delete before adding symlinks
    create_dirs_before_symlink ["config"] # Directories to create before adding symlinks
    symlinks({"config/local.config.php" => "config/local.config.php"})
    action :deploy
    restart_command do
      service "apache2" do action :restart; end
    end
  end
end
