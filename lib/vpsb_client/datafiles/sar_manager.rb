module VpsbClient
  module Datafiles
    class SarManager
      class NotFoundError < StandardError; end
      class PermissionDeniedError < StandardError; end
      class SadfError < StandardError; end

      attr_reader :sadf_runner

      def initialize(orig_path, target_path, sadf = Sadf)
        raise NotFoundError, "#{orig_path} is not a directory" unless File.directory?(orig_path)
        @orig_path = orig_path
        @target_path = target_path
        @sadf_runner = sadf
      end

      def run
        create_target_path
        create_daily_formatted
        create_current_day_temp_formatted
      end

      private

      def create_target_path
        if File.directory?(@target_path)
          raise PermissionDeniedError, "#{@target_path} is not writable" unless File.writable?(@target_path)
          return
        end
        raise PermissionDeniedError unless File.writable?(File.dirname(@target_path))
        Dir.mkdir(@target_path, 0755)
      end

      def create_daily_formatted
        raw_sar_filenames = Dir.glob("#{@orig_path}/sa*")
        raw_sar_filenames.each do |filename|
          filename.match /sa(?<num>\d+)$/ do |matchdata|
            fileday = matchdata[:num]
            next if fileday.to_i == Time.now.day

            formatted_filename = "#{@target_path}/formatted_sa#{fileday}"
            next if File.exist?(formatted_filename)
            sadf(filename, formatted_filename)
          end
        end
      end

      def create_current_day_temp_formatted
        sa_filename = "#{@orig_path}/sa#{Time.now.strftime('%Y%m%d')}"
        formatted_filename = "#{@target_path}/formatted_sa#{'%02d' % Time.now.day}"
        File.delete(formatted_filename) if File.exist?(formatted_filename)
        sadf(sa_filename, formatted_filename)
      end

      def sadf(src, dest)
        sadf_runner.run(src, dest)
      end
    end

    class Sadf
      SADF = '/usr/bin/sadf'

      def self.run(src, dest)
        raise NotFoundError unless File.executable?(SADF)
        cmd = "#{SADF} -d #{src} -U > #{dest}"
        ret = system cmd
        raise VpsbClient::Datafiles::SarManager::SadfError, "\"#{cmd}\" failed" unless ret
      end
    end
  end
end
