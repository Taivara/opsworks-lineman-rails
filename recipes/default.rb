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
      f.print('-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAztrnd4/31X1CTBkHZSWEozTl6yRmXcIWh02xpLxyQ2MUqkMF\nJOY8fzB0BZgns/9gG2vrFSSRDvfKOf5ddhUpzj9qWo70ZzECQzeMnFBP6wh+UgN+\nFk6lGS+aIGFB6b9VEA1gyCPEuas2hjAYaoMKTodnqVSG0sW7pO/StRq8pRqdmxE/\nHUshSzoAbr/2ukIwSfHlaRKGC/wa8iTBsQAyV6gvW73oOfqsKQ/lOCD2OwanWyqf\niLF9IECRWOvOLvD8Sqo0Augvh+aiDYpnJBfM9gvBC8k07e6AzxERfsYi2XQ6grPE\nRMVYg88g9ZEXIQtWM7ewpzaKV0uFtjVSuC9ACQIDAQABAoIBAHDQFfiw/brjC2sx\nI0VYhtPzn4j0Wxe7KEo2ZzGuzKpPuQ96aa3MGyZKqJv8dXrHRgTugFERlkMRhKrI\nPPSPajNfhoNI/6Xfppo+C2OcsVk/UpUr7nIABi6MNYR/RlFS1fNhOG0uhLW12JCq\nXkaInPBjDHfe74C38jRrzwCSSlvIAzcniTjfo4L41Ep0pd6ukwvR8F9uNFoDulmW\nAD70IzlwfGs41M56ME1plg7Cx6IlWQcoHHD9n3GxM8Vc65oYzlyC0nxZWxkX4XD8\n5ZcPAYt4CZn/uGaO3kTnXEFUqMTqoUMauIlGmhGKxr+Z2DX4qjM4TIX6fI4pl36v\nHxjwhHkCgYEA5nklh2L8coPKsMzwKzKOF4e3nnCYWbFnJKJDsI49CehScSvryYDT\nUcqZjOHzRH63PNziOaSQHaVHCooYP0Mycn3gfC9z8IrEpHvvmth6Q/sgZNHzJUHj\nCiJu/aaCauk+lMN5V0JSt8hu0bLALH2cgNKx8iVKg//NdMVOM8LZKvMCgYEA5cQW\nX97NDdlS+1Iom2OSrb++DOqXoHSYZcO41FzgKiDWLkuhePXtVOZVqNNfOhZoHjWt\nFysCae2ZCbu58+sYxHcaM9P/45QYgOv2sCIKUF1kQS4m5MgGyaj39hKeF+6yB3V7\n3U1m19piLyCpS5ctzByTFvKFzG+ZpN9DtEfOsBMCgYEAzfVZKkG1I4jO62xY++Fz\nxWdNGdO48f5tE/nFz9NsjJwGgIglb68mKSOKULHiuUUb7tHdgHGlMDjw4WRDAtXE\nETiYEaI+U6lOzUbL+m6V5IZYjoBobtUQVZAr65SPW4cQm9SLbQUh8oa1McQxpBCk\neSLQTnowuwEv07g2iF8Jvy0CgYEAwTsjxgTOVrNKgmoaFHStSspSvvIcCqmD8TGl\nI5PoQgXTmqOobN4GdrwvlggNsgBeF+n0Y+Ob6BIV/oWOYYB6F+BCfQvxzCckZGgN\n0xsNqYCha9+wff9rFfWwc5Y8tsvblUJMpVUPBMF4iUHintvJfDsbyNS1ibThdjL9\n8YPiY1kCgYBxOsu4U5RwsLt4FeSM2Pe0+Z2RvNONPDxnGQsjvBWywV8J9oBgjnPY\nVLykmLUV27pCnM6cwM2Sgy8QkaEmQ6lhJjTmriR0nHGd6lQXKDeSUIudUcDnVOAU\n3NHaKL2W/aCVYO78jWl8bQ0PpMR7iVmEQMWp9vhSBlskRghaZMCZMg==\n-----END RSA PRIVATE KEY-----\n')
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

  # deploy_revision node['hello_app']['deploy_dir'] do
  #   scm_provider Chef::Provider::Git 
  #   repo node['hello_app']['deploy_repo']
  #   revision node['hello_app']['deploy_branch']
  #   if secrets["deploy_key"]
  #     git_ssh_wrapper "#{node['hello_app']['deploy_dir']}/git-ssh-wrapper" # For private Git repos 
  #   end
  #   enable_submodules true
  #   shallow_clone false
  #   symlink_before_migrate({}) # Symlinks to add before running db migrations
  #   purge_before_symlink [] # Directories to delete before adding symlinks
  #   create_dirs_before_symlink ["config"] # Directories to create before adding symlinks
  #   symlinks({"config/local.config.php" => "config/local.config.php"})
  #   # migrate true
  #   # migration_command "php app/console doctrine:migrations:migrate" 
  #   action :deploy
  #   restart_command do
  #     service "apache2" do action :restart; end
  #   end
  # end
end
