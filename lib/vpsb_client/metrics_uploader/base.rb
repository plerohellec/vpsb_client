module VpsbClient
  module MetricsUploader
    class Base
      attr_reader :created_metric_ids

      def initialize(config, http_client, trial_id, interval_length, interval_start_time, csrf_token_proc)
        @config = config
        @http_client = http_client
        @trial_id = trial_id
        @interval_length = interval_length
        @interval_start_time = interval_start_time
        @csrf_token_proc = csrf_token_proc
      end

      def upload
        @created_metric_ids = []
        if Time.now < @interval_start_time.to_time + @interval_length
          VpsbClient.logger.debug "skipping #{@interval_length} interval because too soon (max=#{@interval_start_time.to_time + @interval_length} now=#{Time.now})"
          return
        end
        builder.each do |interval|
          upload_request = Api::PostMetricRequest.new(@http_client, @trial_id, interval, @csrf_token_proc.call)
          http_response = Api::Response.new(upload_request.run)
          unless http_response.success?
            VpsbClient.logger.debug "Failed to upload metric (interval_length=#{@interval_length} interval=#{interval.inspect})"
            return
          end
          @created_metric_ids << Api::PostMetricRequest.metric_id(http_response)
        end
      end

      private

      def builder
        raise NotImplementedError
      end
    end
  end
end
