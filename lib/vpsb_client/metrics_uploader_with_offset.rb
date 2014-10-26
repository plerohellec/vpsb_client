module VpsbClient
  class MetricsUploaderWithOffset < MetricsUploader

    private
    def builder
      return @builder if @builder
      @builder = Builders::MetricsInterval.new(@config['formatted_sar_path'],
                                               @config['timing_path'],
                                               oldest_valid_started_at,
                                               @len,
                                               offset_by_start_time: Time.now)
    end

    def oldest_valid_started_at
      return @oldest_valid_started_at if @oldest_valid_started_at
      if @last_metric_started_at
        @oldest_valid_started_at = @last_metric_started_at + @len
      else
        @oldest_valid_started_at = Time.at((Time.now - @len).to_i)
      end
      VpsbClient.logger.debug "len=#{@len} last_metric_started_at=#{@last_metric_started_at}"
      @oldest_valid_started_at
    end
  end
end
