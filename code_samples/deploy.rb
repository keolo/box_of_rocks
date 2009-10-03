# List of config settings:
# http://labs.peritor.com/webistrano/wiki/ConfigurationParameter
#
# List tasks:
# cap -T
#
# Automated environment setup:
# http://www.viget.com/extend/building-an-environment-from-scratch-with-capistrano-2/
#
# invoke_command checks the use_sudo variable to determine how to run the mongrel_rails command

require 'capistrano/ext/multistage'
require 'thinking_sphinx/deploy/capistrano'

ssh_options[:port] = 22222

# set :default_stage, 'staging'
#
set :project, 'example'

set :repository, "git@github.com:#{project}/#{project}.git"

set :scm, :git

set :user, 'deploy'
set :runner, user
set :branch, 'master'

set :deploy_to, "/home/#{user}/#{project}"

set :deploy_via, :remote_cache

after 'deploy:setup', 'thinking_sphinx:shared_sphinx_folder'
after 'deploy:update_code', 'app:create_symlinks'
after 'deploy:symlink', 'app:update_crontab'
after 'deploy:restart', 'app:status'

# after 'deploy:update_code', 'deploy:web:disable'
# after 'deploy:restart', 'deploy:web:enable'

namespace :deploy do
  # Overrides default Capistrano task
  desc 'Restart Mongrel and Nginx.'
  task :restart do
    mongrel::restart
    nginx::restart
  end
end

namespace :app do
  desc 'Create symbolic links.'
  task :create_symlinks do
    # Symlink assets
    run "rm -rf #{release_path}/public/assets"
    run "ln -nfs /home/ftp #{release_path}/public/assets"

    # Symlink database config
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"

    # Symlink server config (useful if you change these files a lot)
    sudo "ln -nfs #{release_path}/config/mongrel/#{stage}.yml /etc/mongrel_cluster/#{stage}.yml"
    sudo "ln -nfs #{release_path}/config/nginx/nginx.conf /etc/nginx/"
    sudo "ln -nfs #{release_path}/config/nginx/#{stage}.conf /etc/nginx/sites-enabled/#{stage}.conf"
  end

  desc 'Update crontab file.'
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{project}_#{stage} --set environment=#{stage}"
  end

  desc 'Get status of Nginx and Mongrel'
  task :status do
    mongrel::status
    nginx::status
    stats::free_disk
    stats::free_memory
  end
end

namespace :mongrel do
  [:start, :stop, :restart, :status].each do |t|
    desc "#{t.to_s.capitalize} mongrel cluster."
    task t do
      sudo "service mongrel_cluster #{t.to_s}"
    end
  end
end

namespace :nginx do
  desc 'Check if syntax in config is valid.'
  task :check do
    sudo '/usr/sbin/nginx -t'
  end

  [:start, :stop, :restart, :status].each do |t|
    desc "#{t.to_s.capitalize} Nginx web server."
    task t do
      sudo "service nginx #{t.to_s}"
    end
  end
end

namespace :stats do
  desc 'Show the amount of free disk space.'
  task :free_disk do
    run 'df -h /'
  end

  desc 'Show the amount of free memory.'
  task :free_memory do
    run 'free -m'
  end
end
