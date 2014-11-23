module VpsbClient
  module Metrics
    class IntervalConfig
      def initialize(fallback_start_time, forced_start_time, interval_length)
        @fallback_start_time = fallback_start_time
        @forced_start_time = forced_start_time
        @interval_length = interval_length
      end

      def aligned?
        if @forced_start_time
          false
        elsif @interval_length < 86400
          true
        else
          false
        end
      end

      def min_start_time
        if @forced_start_time
          @forced_start_time
        elsif aligned?
          lower_boundary_time(@fallback_start_time)
        else
          @fallback_start_time
        end
      end

      def min_end_time
        min_start_time + @interval_length
      end

      def length
        @interval_length
      end

      private

      def lower_boundary_time(t)
        Time.at((t.to_i / @interval_length.to_i) * @interval_length.to_i)
      end
    end
  end
end
