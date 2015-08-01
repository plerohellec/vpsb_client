module VpsbClient
  module Metrics
    class Uploader
      def initialize(http_client, trial_id)
        @http_client = http_client
        @trial_id = trial_id
      end

      def upload(metric)
        upload_request = Api::PostMetricRequest.new(@http_client, @trial_id, metric)
        http_response = Api::Response.new(upload_request.run)
        Api::PostMetricRequest.metric_id(http_response)
      end
    end
  end
end
