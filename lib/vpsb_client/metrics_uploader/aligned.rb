require "#{VPSB_BASE_PATH}/vpsb_client/metrics_uploader/base"
require "#{VPSB_BASE_PATH}/vpsb_client/metrics_uploader/interval_start_time"

module VpsbClient
  module MetricsUploader
    class Aligned < Base
      private

      def builder
        return @builder if @builder
        @builder = Builders::MetricsInterval.new(@config['formatted_sar_path'],
                                                 @config['timing_path'],
                                                 @interval_start_time.to_time,
                                                 @interval_length,
                                                 boundary_offset: @interval_start_time.offset)
      end
    end
  end
end
