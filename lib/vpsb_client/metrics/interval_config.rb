module VpsbClient
  module Metrics
    class IntervalConfig
      def initialize(start_time, interval_length, options={})
        @start_time = start_time
        @interval_length = interval_length
        @force = options.fetch(:force, false)
      end

      def aligned?
        if @force
          false
        elsif @interval_length < 86400
          true
        else
          false
        end
      end

      def min_start_time
        if @force
          @start_time
        elsif aligned?
          upper_boundary_time(@start_time)
        else
          @start_time
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

      def upper_boundary_time(t)
        lower_boundary_time(t) + @interval_length.to_i
      end
    end
  end
end
