require "#{VPSB_BASE_PATH}/vpsb_client/metrics_uploader/base"

module VpsbClient
  module MetricsUploader
    class Aligned < Base
      private

      def builder
        return @builder if @builder
        @builder = Builders::MetricsInterval.new(@config['formatted_sar_path'],
                                          @config['timing_path'],
                                          oldest_valid_started_at,
                                          @len)
      end

      def oldest_valid_started_at
        return @oldest_valid_started_at if @oldest_valid_started_at
        last_started_at = @last_metric_started_at
        last_started_at ||= start_boundary_time(DateTime.parse(@trial['started_at']).to_time)
        VpsbClient.logger.debug "len=#{@len} last_metric_started_at=#{last_started_at}"
        @oldest_valid_started_at = last_started_at + @len
      end

      def start_boundary_time(t)
        Time.at((t.to_i / @len.to_i) * @len.to_i)
      end
    end
  end
end
