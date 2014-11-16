module VpsbClient
  module Metrics
    class Manager
      attr_reader :created_metric_ids

      def initialize(http_client, csrf_token_proc, trial_id, sar_path, timing_path, interval_config)
        @min_start_time = interval_config.min_start_time
        @builder = IntervalBuilder.new(sar_path, timing_path, @min_start_time, interval_config.length)
        @uploader = Uploader.new(http_client, csrf_token_proc, trial_id)
        @created_metric_ids = []
      end

      def run
        @builder.each do |metric|
          break if metric[:started_at] < @min_start_time
          @created_metric_ids << @uploader.upload(metric)
        end
      end
    end
  end
end
