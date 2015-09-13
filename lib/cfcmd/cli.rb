require "thor"
require "toml"
require "fog"

module CFcmd
  class CLI < Thor
    require_relative "cli/ls"

    class_option :region, :type => :string, aliases: '-R'
    class_option :debug, :type => :boolean, default: false

    def initialize(*)
      super
      ENV['EXCON_DEBUG'] = 'true' if options['debug']
    end

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
      config      = {}

      print "Rackspace Username: "
      config[:username] = STDIN.gets.chomp

      print "Rackspace API key: "
      config[:api_key] = STDIN.gets.chomp

      print "Default Region [ord]: "
      region = STDIN.gets.chomp
      region = 'ord' unless region.length > 0
      config[:region] = region

      File.open config_file, 'w' do |file|
        file.write TOML::Generator.new(rackspace: config).body
      end

      puts "Wrote configuration to #{ config_file }"
    end

    map '--configure' => 'configure'

    desc "ls [cf://BUCKET[/PREFIX]] [options]", "List objects or buckets"
    def ls(uri = nil)
      puts Ls.new(connection, uri).run
    end

    desc "la", "List all objects in all buckets"
    def la
      connection.directories.each do |dir|
        puts Ls.new(connection, dir).ls_files
        print "\n"
      end
    end

    method_option :public, :type => :boolean, default: false

    desc "mb cf://BUCKET", "Make bucket"
    def mb(uri)
      bucket = URI(uri).host or abort("Invalid bucket URI: #{ uri }")
      connection.directories.create(key: bucket, public: options['public'])
      puts "Bucket 'cf://#{ bucket }/' created"
    end

    desc "rb cf://BUCKET", "Remove Bucket"
    def rb(uri)
      bucket = URI(uri).host or abort("Invalid bucket URI: #{ uri }")
      connection.delete_container(bucket)
      puts "Bucket 'cf://#{ bucket }/' deleted"
    end

    desc "put FILE [FILE...] cf://BUCKET[/PREFIX]", "Put file(s) into bucket"
    def put(*args)
      abort "ERROR: not enough parameters for command 'put'" unless args.length > 1
      uri       = URI(args.pop)
      filenames = args.select { |filename| File.exist?(filename) }
      abort "ERROR: Parameter problem: Destination must be CFUri. Got: #{ uri.host }" if uri.scheme.nil?
      abort "ERROR: Parameter problem: Nothing to upload." unless filenames.length > 0

      bucket = connection.directories.get(uri.host, prefix: uri.path[1..-1])
      abort "ERROR: The specified bucket does not exist" unless bucket

      filenames.each_with_index do |filename, i|
        begin
          file  = File.open(filename, 'r')
          type  = MIME::Types.type_for(filename).first.content_type
          chunk = 0
          size  = File.size(file)
          key   = uri.path[1..-1] || ''
          key  += '/' if key.length > 0
          key  += File.basename(file)

          print "#{ File.basename(file) } -> cf://#{ bucket.key }/#{ key }"
          print "  [#{ i + 1 } of #{ filenames.length }]" if filenames.length > 0
          print "\n"
          print " %-#{ size.to_s.length }s of #{ size }    0\%" % '0'
          bucket.files.create(key: key, content_type: type) do
            chunk  += size < 1048576 ? size : 1048576
            percent = ((chunk.to_f / size) * 100).round.to_s
            print "\r %-#{ size.to_s.length }s of #{ size }  %-3s\%" % [chunk, percent]

            file.read(1048576)
          end
          puts "\r #{ size } of #{ size }  100% done"
        ensure
          file.close
        end
      end
    end
  end
end
