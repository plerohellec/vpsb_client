require "#{VPSB_BASE_PATH}/vpsb_client/metrics/interval_builder"
require "#{VPSB_BASE_PATH}/vpsb_client/metrics/interval_config"
require "#{VPSB_BASE_PATH}/vpsb_client/metrics/uploader"

module VpsbClient
  module Metrics
    class Manager
      attr_reader :created_metric_ids

      def initialize(builder, uploader, interval_config)
        @interval_config = interval_config
        @builder = builder
        @uploader = uploader
        @created_metric_ids = []
      end

      def run
        if @interval_config.min_end_time > Time.now
          VpsbClient.logger.info "Skipping #{@interval_config.length} because too early (min_end_time=#{@interval_config.min_end_time})"
          return
        end

        @builder.each do |metric|
          break if metric[:started_at] < @interval_config.min_start_time
          @created_metric_ids << @uploader.upload(metric)
        end
      end
    end
  end
end
