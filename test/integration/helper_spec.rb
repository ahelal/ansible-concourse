require 'rubygems'
require 'serverspec'
require 'pathname'
require 'net/ssh'

RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true
  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # By default use ssh
  verify_conn = ENV['KITCHEN_VERIFY_CONN'] || 'ssh'
  if verify_conn == 'ssh'
    set :host, ENV['KITCHEN_HOSTNAME']
    # ssh options at http://net-ssh.github.io/net-ssh/Net/SSH.html#method-c-start
    set :ssh_options,
        user: ENV['KITCHEN_USERNAME'],
        port: ENV['KITCHEN_PORT'],
        auth_methods: ['publickey'],
        keys: [ENV['KITCHEN_SSH_KEY']],
        keys_only: true,
        paranoid: false,
        use_agent: false,
        verbose: :error
    set :backend, :ssh
    set :request_pty, true
    puts "serverspec config ssh '#{ENV['KITCHEN_USERNAME']}@#{ENV['KITCHEN_HOSTNAME']} -p #{ENV['KITCHEN_PORT']} -i #{ENV['KITCHEN_SSH_KEY']}'"
  elsif verify_conn == 'exec'
    puts 'serverspec :backend, :exec'
    set :backend, :exec
  else
    puts "invalid serverspec backend #{verify_conn}"
  end
end
