module VpsbClient
  module Builders
    class SystemInfoParser
      class NoMatchError < StandardError; end

      def initialize(cmd)
        @cmd = cmd
      end

      def lines
        IO.popen(@cmd) { |f| f.readlines }
      end

      def find_matches(regex)
        regex = Regexp.new(regex)
        matches = nil
        lines.each do |line|
          matches = regex.match(line)
          break if matches
        end
        matches
      end

      def find_matches!(regex)
        matches = find_matches(regex)
        raise NoMatchError, "Cannot find /#{regex}/" unless matches
        matches
      end
    end

    class MemoryParser < SystemInfoParser
      attr_reader :used, :free, :total

      REGEX_CACHE = 'cache:\s+(?<used>\d+)\s+(?<free>\d+)$'
      REGEX_AVAIL = '^Mem:\s+\d+\s+(?<used>\d+)\s+\d+\s+\d+\s+\d+\s+(?<avail>\d+)'
      REGEX_TOTAL = '^Mem:\s+(?<total>\d+)'

      def initialize
        super('free')
      end

      def parse
        matches = find_matches(REGEX_CACHE)
        if matches
          @used = matches[:used].to_i
          @free = matches[:free].to_i
        elsif matches = find_matches(REGEX_AVAIL)
          @used = matches[:used].to_i
          @free = matches[:avail].to_i
        else
          raise NoMatchError, "No regex matches 'free' output"
        end
        matches = find_matches!(REGEX_TOTAL)
        @total = matches[:total].to_i
      end
    end

    class UnameParser < SystemInfoParser
      attr_reader :kernel
      # Linux lino 3.12.6-x86_64-linode36 #2 SMP Mon Jan 13 18:54:10 EST 2014 x86_64 x86_64 x86_64 GNU/Linux
      REGEX = Regexp.new(/\w+ \S+ (?<kernel>\d+\.\d+\.\d+)-?(?<type>[^\-\s]+)?[\-\s]/)

      def initialize
        super('uname -a')
      end

      def parse
        matches = find_matches!(REGEX)
        @kernel  = matches[:kernel]
      end
    end

    class CpuinfoParser < SystemInfoParser
      attr_reader :model, :num, :mhz
      # model name  : Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz
      REGEX = Regexp.new('^model name\s*:\s*(?<model>.*$)')
      REGEX_PROCESSOR = Regexp.new('^Processor\s*:\s*(?<model>.*$)')

      def initialize
        super('cat /proc/cpuinfo')
      end

      def parse
        matches = find_matches(REGEX)
        matches = find_matches!(REGEX_PROCESSOR) unless matches
        @model = matches[:model]
        parse_num_processors
        parse_cpu_speed
      end

      private
      def parse_num_processors
        @num = 0
        lines.each do |line|
          if line =~ /^processor\s*:\s*(?<num>\d+)/
            @num += 1
          end
        end
      end

      def parse_cpu_speed
        matches = find_matches(/^cpu MHz\s*:\s*(?<mhz>\d+)/)
        if matches
          @mhz = matches[:mhz].to_i
        else
          @mhz = nil
        end
      end
    end

    class IssueParser < SystemInfoParser
      attr_reader :os

      REGEX = '^(?<os>[^\\\\]+)(?: \\\\n \\\\l)?$'

      def initialize
        super('cat /etc/issue')
      end

      def parse
        matches = find_matches!(REGEX)
        @os = matches[:os]
      end
    end
  end
end
