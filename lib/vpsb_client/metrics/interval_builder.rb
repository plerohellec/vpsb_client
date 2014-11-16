require "#{File.expand_path('../..', __FILE__)}/datafiles/formatted_sar_log_parser"
require "#{File.expand_path('../..', __FILE__)}/datafiles/timing_log_parser"

module VpsbClient
  module Metrics
    class IntervalBuilder
      class FileNotFound < StandardError; end

      VALID_METRIC_KEYS = [ :trial_id, :started_at, :duration_seconds, :num_requests, :resptime_total_ms, :resptime_db_ms, :resptime_view_ms, :cpu_idle, :cpu_steal, :iowait, :p50_total_ms, :p75_total_ms, :p95_total_ms, :p99_total_ms, :p75_iowait_pct, :p95_iowait_pct, :p99_iowait_pct,:p75_cpusteal_pct, :p95_cpusteal_pct, :p99_cpusteal_pct, :p75_cpuidle_pct, :p95_cpuidle_pct, :p99_cpuidle_pct ]

      def initialize(sar_path, timing_path, pole_time, interval_length)
        @sar_path = sar_path
        @timing_path = timing_path
        @pole_time = pole_time
        @interval_length = interval_length
      end

      def each(&block)
        return enum_for(:each) unless block_given?

        sar_filenames = Dir.glob("#{@sar_path}/formatted_sa*")
        timing_filenames = Dir.glob("#{@timing_path}/timings.log*")

        sar_filenames.reject!    { |f| f =~ /\.gz$/ }
        timing_filenames.reject! { |f| f =~ /\.gz$/ }

        raise FileNotFound, "No file matching #{@sar_path}/formatted_sa*" unless sar_filenames.any?
        raise FileNotFound, "No file matching #{@timing_path}/timings.log*" unless timing_filenames.any?

        builder_options = { offset_by_start_time: @pole_time }

        sar_files = LogfileInterval::LogfileSet.new(sar_filenames, Datafiles::FormattedSarLogParser, :desc)
        timing_files = LogfileInterval::LogfileSet.new(timing_filenames, Datafiles::TimingLogParser, :desc)

        begin
          sar_builder = LogfileInterval::IntervalBuilder.new(sar_files, Datafiles::FormattedSarLogParser, @interval_length, builder_options)
          timing_builder = LogfileInterval::IntervalBuilder.new(timing_files, Datafiles::TimingLogParser, @interval_length, builder_options)

          sar_enum = sar_builder.each_interval
          timing_enum = timing_builder.each_interval
          while(timing_interval = timing_enum.next) do
            while(sar_interval = sar_enum.next) do
              break if sar_interval.start_time == timing_interval.start_time
              raise "sar_interval older than timing_interval: #{sar_interval.start_time} > #{timing_interval.start_time}" if sar_interval.start_time > timing_interval.start_time
            end

            yield convert_to_metric(timing_interval, sar_interval)
          end
        rescue StopIteration
        end
      end

      private

      def convert_to_metric(timing_interval, sar_interval)
        interval = timing_interval.to_hash.merge(sar_interval)
        interval[:duration_seconds] = timing_interval.length
        interval[:started_at] = timing_interval.start_time

        pxx_total_ms = timing_interval[:pxx_total_ms]
        interval[:p50_total_ms] = pxx_total_ms[50]
        interval[:p75_total_ms] = pxx_total_ms[75]
        interval[:p95_total_ms] = pxx_total_ms[95]
        interval[:p99_total_ms] = pxx_total_ms[99]

        pxx_iowait = sar_interval[:pxx_iowait]
        interval[:p75_iowait_pct] = pxx_iowait[75]
        interval[:p95_iowait_pct] = pxx_iowait[95]
        interval[:p99_iowait_pct] = pxx_iowait[99]

        pxx_cpusteal = sar_interval[:pxx_cpusteal]
        interval[:p75_cpusteal_pct] = pxx_cpusteal[75]
        interval[:p95_cpusteal_pct] = pxx_cpusteal[95]
        interval[:p99_cpusteal_pct] = pxx_cpusteal[99]

        pxx_cpuidle = sar_interval[:pxx_cpuidle]
        interval[:p75_cpuidle_pct] = 100.0 - pxx_cpuidle[75]
        interval[:p95_cpuidle_pct] = 100.0 - pxx_cpuidle[95]
        interval[:p99_cpuidle_pct] = 100.0 - pxx_cpuidle[99]

        interval.select! { |k| VALID_METRIC_KEYS.include?(k) }
      end
    end
  end
end
