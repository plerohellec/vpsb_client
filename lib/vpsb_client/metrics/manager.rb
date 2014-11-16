require "#{VPSB_BASE_PATH}/vpsb_client/metrics/interval_builder"
require "#{VPSB_BASE_PATH}/vpsb_client/metrics/interval_config"
require "#{VPSB_BASE_PATH}/vpsb_client/metrics/uploader"

module VpsbClient
  module Metrics
    class Manager
      attr_reader :created_metric_ids

      def initialize(builder, uploader, min_start_time)
        @min_start_time = min_start_time
        @builder = builder
        @uploader = uploader
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
