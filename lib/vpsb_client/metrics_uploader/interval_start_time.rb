module VpsbClient
  module MetricsUploader
    class UnalignedIntervalStartTime
      attr_reader :interval_start_time

      def initialize(interval_start_time, interval_length)
        @interval_start_time = min_interval_start_time
        @interval_length = interval_length
      end

      def to_time
        @interval_start_time
      end

      def offset
        @interval_start_time - lower_aligned_boundary
      end

      private

      def lower_aligned_boundary
        Time.at((@interval_start_time.to_i / @interval_length.to_i) * @interval_length.to_i)
      end
    end

    class AlignedIntervalStartTime
      attr_reader :metric_start_time, :trial_start_time, :interval_length

      def initialize(metric_start_time, trial_start_time, interval_length)
        @metric_start_time = metric_start_time
        @trial_start_time = trial_start_time
        @interval_length = interval_length
      end

      def interval_start_time
        return @interval_start_time if @interval_start_time
        start_time = metric_start_time || trial_start_time
        start_time = align_on_lower_boundary(start_time)
        @interval_start_time = start_time + interval_length
      end

      def to_time
        interval_start_time
      end

      def offset
        0
      end

      def align_on_lower_boundary(t)
        Time.at((t.to_i / @interval_length.to_i) * @interval_length.to_i)
      end
    end

  end
end
