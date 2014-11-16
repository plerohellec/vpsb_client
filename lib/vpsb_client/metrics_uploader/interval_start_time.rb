module VpsbClient
  module MetricsUploader
    module IntervalConfig
      class Base
        def min_start_time
          raise NotImplementedError
        end

        def offset
          NotImplementedError
        end

        def length
          @interval_length
        end

        private

        def lower_boundary_time(t)
          Time.at((t.to_i / @interval_length.to_i) * @interval_length.to_i)
        end
      end

      class Unaligned < Base
        attr_reader :interval_start_time

        def initialize(interval_start_time, interval_length)
          @interval_start_time = min_interval_start_time
          @interval_length = interval_length
        end

        def min_start_time
          @interval_start_time
        end

        def offset
          @interval_start_time - lower_aligned_boundary(@interval_start_time)
        end
      end

      class Aligned < Base
        def initialize(time_in_interval, interval_length)
          @time_in_interval = time_in_interval
          @interval_length = interval_length
        end

        def min_start_time
          return @interval_start_time if @interval_start_time
          @interval_start_time = lower_boundary_time(@time_in_interval)
        end

        def offset
          0
        end
      end
    end
  end
end
