module VpsbClient
  class MetricsUploader
    attr_reader :created_metric_ids

    def initialize(config, trial, len, last_metric_started_at, csrf_token)
      @config = config
      @trial = trial
      @len = len
      @last_metric_started_at = last_metric_started_at
      @csrf_token = csrf_token
    end

    def upload
      @created_metric_ids = []
      if Time.now < oldest_valid_started_at + @len
        VpsbClient.logger.debug "skipping #{@len} interval because too soon"
        return
      end
      builder = Builders::MetricsInterval.new(@config['formatted_sar_path'],
                                              @config['timing_path'],
                                              oldest_valid_started_at,
                                              @len)
      builder.each do |interval|
        upload_request = Api::PostMetricRequest.new(@http_client, @trial['id'], interval, @csrf_token)
        http_response = Api::Response.new(upload_request.run)
        unless http_response.success?
          VpsbClient.logger.debug "Failed to upload metric (len=#{@len} interval=#{interval.inspect})"
          return
        end
        @created_metric_ids << Api::PostMetricRequest.metric_id(http_response)
      end
    end

    private

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
