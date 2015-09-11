class CFcmd::CLI
  class Ls
    attr_reader :connection, :uri_or_dir

    def initialize(connection, uri_or_dir = nil)
      @connection = connection
      @uri_or_dir = uri_or_dir
    end

    def run
      return ls_files if directory
      ls_directories
    end

    def ls_directories
      directories = connection.directories.map do |dir|
        {
          name:  "cf://#{ dir.key }",
          files: ::CFcmd::Util.number_to_human(dir.count),
          size:  ::CFcmd::Util.number_to_human_size(dir.bytes)
        }
      end

      files_max = directories.map {|dir| dir[:files].length }.max
      size_max  = directories.map {|dir| dir[:size].length }.max

      output = directories.map do |dir|
        ["%-#{ files_max }s" % dir[:files], "%-#{ size_max }s" % dir[:size], dir[:name]].join(' ')
      end

      output.join("\n")
    end

    def ls_files
      files     = directory.files
      max_bytes = files.map(&:content_length).max.to_s.length

      output = files.map do |file|
        "#{ file.last_modified }  %-#{ max_bytes }s cf://#{ directory.key }/#{ file.key }" % file.content_length.to_s
      end

      output.join("\n")
    end

  private

    def directory
      @directory ||= case uri_or_dir
      when String
        uri    = URI(uri_or_dir)
        bucket = uri.host
        prefix = uri.path[1..-1]

        connection.directories.get(bucket, prefix: prefix)
      when Fog::Storage::Rackspace::Directory
        uri_or_dir
      else
        nil
      end
    end

  end
end
