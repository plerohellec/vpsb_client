module VpsbClient
  module Builders
    class SystemInfoParser
      class NoMatchError < StandardError; end

      def initialize(filepath)
        raise Errno::ENOENT unless File.exist?(filepath)
        @filepath = filepath
      end

      def lines
        File.readlines(@filepath)
      end

      def find_matches(regex)
        regex = Regexp.new(regex)
        matches = nil
        lines.each do |line|
          matches = regex.match(line)
          break if matches
        end
        raise NoMatchError, "Cannot find /#{regex}/ in #{@filepath}" unless matches
        matches
      end
    end

    class MemoryParser < SystemInfoParser
      attr_reader :used, :free

      REGEX = 'cache:\s+(?<used>\d+)\s+(?<free>\d+)$'

      def parse
        matches = find_matches(REGEX)
        @used = matches[:used].to_i
        @free = matches[:free].to_i
      end
    end

    class UnameParser < SystemInfoParser
      attr_reader :kernel, :os_type
      # Linux lino 3.12.6-x86_64-linode36 #2 SMP Mon Jan 13 18:54:10 EST 2014 x86_64 x86_64 x86_64 GNU/Linux
      REGEX = Regexp.new(/\w+ \w+ (?<kernel>\d+\.\d+\.\d+)-(?<type>[^\-]+)-/)

      def parse
        matches = find_matches(REGEX)
        @kernel  = matches[:kernel]
        @os_type = matches[:type]
      end
    end

    class CpuinfoParser < SystemInfoParser
      attr_reader :model, :num
      # model name  : Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz
      REGEX = Regexp.new('^model name\s*:\s*(?<model>.*$)')

      def parse
        matches = find_matches(REGEX)
        @model = matches[:model]
        parse_num_processors
      end

      private
      def parse_num_processors
        @num = 0
        File.open(@filepath) do |f|
          f.each_line do |line|
            if line =~ /^processor\s*:\s*(?<num>\d+)/
              @num += 1
            end
          end
        end
      end
    end

    class IssueParser < SystemInfoParser
      attr_reader :os

      REGEX = '^(?<os>[^\\\\]+)(?: \\\\n \\\\l)?$'

      def parse
        matches = find_matches(REGEX)
        @os = matches[:os]
      end
    end
  end
end
