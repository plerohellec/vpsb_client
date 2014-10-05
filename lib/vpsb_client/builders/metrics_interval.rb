require "#{File.expand_path('../..', __FILE__)}/datafiles/formatted_sar_log_parser"
require "#{File.expand_path('../..', __FILE__)}/datafiles/timing_log_parser"

module VpsbClient
  module Builders
    class MetricsInterval
      def initialize(sar_path, timing_path, start_date, interval_length)
        @sar_path = sar_path
        @timing_path = timing_path
        @start_date = start_date
        @interval_length = interval_length
      end

      def each(&block)
        return enum_for(:each) unless block_given?

        sar_filenames = Dir.glob("#{@sar_path}/formatted_sa*")
        sar_files = LogfileInterval::LogfileSet.new(sar_filenames, Datafiles::FormattedSarLogParser, :desc)

        timing_filenames = Dir.glob("#{@timing_path}/timings.log*")
        timing_files = LogfileInterval::LogfileSet.new(timing_filenames, Datafiles::TimingLogParser, :desc)

        begin
          sar_builder = LogfileInterval::IntervalBuilder.new(sar_files, Datafiles::FormattedSarLogParser, @interval_length)
          timing_builder = LogfileInterval::IntervalBuilder.new(timing_files, Datafiles::TimingLogParser, @interval_length)

          sar_enum = sar_builder.each_interval
          timing_enum = timing_builder.each_interval
          while(timing_interval = timing_enum.next) do
            break if timing_interval.start_time <= @start_date

            while(sar_interval = sar_enum.next) do
              break if sar_interval.start_time == timing_interval.start_time
              raise "sar_interval older than timing_interval: #{sar_interval.start_time} > #{timing_interval.start_time}" if sar_interval.start_time > timing_interval.start_time
            end
            interval = timing_interval.to_hash.merge(sar_interval)
            interval[:duration_seconds] = timing_interval.length
            interval[:started_at] = timing_interval.start_time
            interval[:p50_total_ms] = timing_interval[:pxx_total_ms][50]
            interval[:p75_total_ms] = timing_interval[:pxx_total_ms][75]
            interval[:p95_total_ms] = timing_interval[:pxx_total_ms][95]
            interval[:p99_total_ms] = timing_interval[:pxx_total_ms][99]
            interval[:p75_iowait_pct] = sar_interval[:pxx_iowait][75]
            interval[:p95_iowait_pct] = sar_interval[:pxx_iowait][95]
            interval[:p99_iowait_pct] = sar_interval[:pxx_iowait][99]
            interval[:p75_cpusteal_pct] = sar_interval[:pxx_cpusteal][75]
            interval[:p95_cpusteal_pct] = sar_interval[:pxx_cpusteal][95]
            interval[:p99_cpusteal_pct] = sar_interval[:pxx_cpusteal][99]
            interval[:p75_cpuidle_pct] = 100.0 - sar_interval[:pxx_cpuidle][75]
            interval[:p95_cpuidle_pct] = 100.0 - sar_interval[:pxx_cpuidle][95]
            interval[:p99_cpuidle_pct] = 100.0 - sar_interval[:pxx_cpuidle][99]
            yield interval
          end
        rescue StopIteration
        end
      end
    end
  end
end
