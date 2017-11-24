require 'zlib'

module VpsbClient
  module Datafiles
    class LogfileDecompressor
      class NotFoundError < StandardError; end

      UNLIMITED_ROTATION_ID = 10000

      def initialize(orig_path, target_path, options = {})
        raise NotFoundError, "#{orig_path} is not a directory" unless File.directory?(orig_path)
        @orig_path = orig_path
        @target_path = target_path
        @filename_prefix = options.fetch(:filename_prefix, '*')
        @max_rotation_id = options.fetch(:max_rotation_id, UNLIMITED_ROTATION_ID)
      end

      def run
        unzip
      end

      private

      def unzip
        timing_logs = Dir.glob("#{@orig_path}/#{@filename_prefix}.log.*.gz")
        VpsbClient.logger.debug "Will gunzip #{timing_logs.inspect}"
        timing_logs.each do |zipfile|
          unzip_file(zipfile)
        end
      end

      def unzip_file(zipfile)
        if md = /[^\/]*\/(?<name>[^\/]+)\.(?<num>\d+)\.gz$/.match(zipfile)
          return if md[:num].to_i > @max_rotation_id
          unzipped_file = "#{@target_path}/#{md[:name]}.#{md[:num]}"
        else
          raise "Cannot convert to unzipped filename #{zipfile}"
        end
        VpsbClient.logger.debug "Will unzip #{zipfile} to #{unzipped_file}"
        File.open(unzipped_file, 'w') do |fout|
          File.open(zipfile) do |fin|
            gz = Zlib::GzipReader.new(fin)
            fout.write(gz.read)
            gz.close
          end
        end
      end
    end
  end
end
