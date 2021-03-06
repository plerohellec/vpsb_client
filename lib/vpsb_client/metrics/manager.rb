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
        now = Time.now
        if @interval_config.min_end_time > now
          VpsbClient.logger.info "Skipping #{@interval_config.length} because too early (min_end_time=#{@interval_config.min_end_time} now=#{now})"
          return
        end

        @builder.each do |metric|
          VpsbClient.logger.debug "metric[:started_at]=#{metric[:started_at]} @interval_config.min_start_time=#{@interval_config.min_start_time}"
          if metric[:started_at] < @interval_config.min_start_time - 1
            VpsbClient.logger.debug "[vpsb] stop builder loop as #{metric[:started_at]} < #{@interval_config.min_start_time}"
            break
          end
          @created_metric_ids << @uploader.upload(metric)
        end
      end
    end
  end
end
