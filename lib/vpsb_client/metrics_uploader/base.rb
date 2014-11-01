module VpsbClient
  module MetricsUploader
    class Base
      attr_reader :created_metric_ids

      def initialize(config, http_client, trial, len, last_metric_started_at, csrf_token_proc)
        @config = config
        @http_client = http_client
        @trial = trial
        @len = len
        @last_metric_started_at = last_metric_started_at
        @csrf_token_proc = csrf_token_proc
      end

      def upload
        @created_metric_ids = []
        if Time.now < oldest_valid_started_at + @len
          VpsbClient.logger.debug "skipping #{@len} interval because too soon (max=#{oldest_valid_started_at + @len} now=#{Time.now})"
          return
        end
        builder.each do |interval|
          upload_request = Api::PostMetricRequest.new(@http_client, @trial['id'], interval, @csrf_token_proc.call)
          http_response = Api::Response.new(upload_request.run)
          unless http_response.success?
            VpsbClient.logger.debug "Failed to upload metric (len=#{@len} interval=#{interval.inspect})"
            return
          end
          @created_metric_ids << Api::PostMetricRequest.metric_id(http_response)
        end
      end

      private

      def builder
        raise NotImplementedError
      end

      def oldest_valid_started_at
        raise NotImplementedError
      end
    end
  end
end
