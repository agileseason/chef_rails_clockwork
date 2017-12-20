#
# Cookbook Name:: chef_rails_clockwork
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

app = AppHelpers.new node['app']

bundle_exec = <<~CMD.gsub(/\n|  +/, ' ')
  RAILS_ENV=#{app.env}
  PATH=/home/#{app.user}/.rbenv/bin:/home/#{app.user}/.rbenv/shims:$PATH
    bundle exec
CMD

systemd_unit "#{app.service(:clockwork)}.service" do
  content <<~SERVICE
    [Unit]
    Description=Clockwork for #{app.name} #{app.env}
    After=syslog.target network.target

    [Service]
    SyslogIdentifier=#{app.service(:clockwork)}.service
    User=#{app.user}
    Group=#{app.group}
    UMask=0002
    WorkingDirectory=#{app.dir(:root)}
    Restart=on-failure

    ExecStart=/bin/bash -c '#{bundle_exec} clockwork #{app.dir(:root)}/config/clock.rb'

    StandardOutput=journal
    StandardError=journal

    [Install]
    WantedBy=multi-user.target
  SERVICE

  triggers_reload true
  verify false
  action %i[create enable start]
end
