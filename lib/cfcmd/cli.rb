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
      end
    end

    desc "ls [cf://BUCKET[/PREFIX]] [options]", "List objects or buckets"
    def ls(uri = nil)
      puts Ls.new(connection, uri).run
    end
  end
end
