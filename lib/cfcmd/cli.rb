require "thor"
require "toml"
require "fog"

module CFcmd
  class CLI < Thor
    require_relative "cli/ls"

    class_option :region, :type => :string, aliases: '-R'

    no_commands do
      def config
        @config ||= TOML.load_file(File.expand_path(ENV['HOME'] + '/.cfcmd'))
      rescue Errno::ENOENT
        abort "Config file not found. You should run 'cfcmd configure' first."
      end

      def region
        options.fetch('region'){ config.fetch('rackspace', {}).fetch('region', 'ord') }
      end

      def connection
        @connection ||= Fog::Storage.new({
          provider:           'Rackspace',
          rackspace_username: config.fetch('rackspace', {}).fetch('username'),
          rackspace_api_key:  config.fetch('rackspace', {}).fetch('api_key'),
          rackspace_region:   region.downcase.to_sym
        })
      rescue Excon::Errors::Unauthorized
        abort "Username or api key is invalid."
      rescue Excon::Errors::SocketError
        abort "Unable to connect to Rackspace."
      end
    end

    desc "configure", "Invoke interactive (re)configuration tool."
    def configure
      config_file = File.expand_path(ENV['HOME'] + '/.cfcmd')
      config      = { rackspace: {} }

      print "Rackspace Username: "
      config[:rackspace][:username] = STDIN.gets.chomp
      print "Rackspace API key: "
      config[:rackspace][:api_key] = STDIN.gets.chomp
      print "Default Region [ord]: "
      region = STDIN.gets.chomp
      region = 'ord' unless region.length > 0
      config[:rackspace][:region] = region

      File.open config_file, 'w' do |file|
        file.write TOML::Generator.new(config).body
      end

      puts "Wrote configuration to #{ config_file }"
    rescue Interrupt
      print "\n"
    end

    map '--configure' => 'configure'

    desc "ls [cf://BUCKET[/PREFIX]] [options]", "List objects or buckets"
    def ls(uri = nil)
      puts Ls.new(connection, uri).run
    end
  end
end
