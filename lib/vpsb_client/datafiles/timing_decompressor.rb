module VpsbClient
  module Datafiles
    class TimingDecompressor
      class NotFoundError < StandardError; end

      def initialize(orig_path, target_path)
        raise NotFoundError, "#{orig_path} is not a directory" unless File.directory?(orig_path)
        @orig_path = orig_path
        @target_path = target_path
      end

      def run
        unzip
      end

      private

      def unzip
        timing_logs = Dir.glob("#{@orig_path}/timings.log.*.gz")
        VpsbClient.logger.debug "Will gunzip #{timing_logs.inspect}"
        timing_logs.each do |zipfile|
          unzip_file(zipfile)
        end
      end

      def unzip_file(zipfile)
        if res = /[^\/]*\/(?<name>[^\/]+)\.gz$/.match(zipfile)
          unzipped_file = "#{@target_path}/#{res[:name]}"
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
