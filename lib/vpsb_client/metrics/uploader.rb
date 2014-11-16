module VpsbClient
  module Metrics
    class Uploader
      def initialize(http_client, csrf_token_proc, trial_id)
        @http_client = http_client
        @csrf_token_proc = csrf_token_proc
        @trial_id = trial_id
      end

      def upload(metric)
        @csrf_token ||= @csrf_token_proc.call
        upload_request = Api::PostMetricRequest.new(@http_client, @trial_id, metric, @csrf_token)
        http_response = Api::Response.new(upload_request.run)
        Api::PostMetricRequest.metric_id(http_response)
      end
    end
  end
end
