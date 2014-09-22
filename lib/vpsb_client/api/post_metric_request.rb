module VpsbClient
  module Api
    class PostMetricRequest < PostRequest

      def initialize(http_client, trial_id, metric, csrf_token)
        super(http_client, csrf_token)
        @trial_id = trial_id
        @metric = metric
      end

      def url_path
        "/admin/metrics"
      end

      def post_params
        @post_params = { metric: @metric.merge(trial_id: @trial_id) }
      end

      def content_type
        'application/json'
      end

      def self.metric_id(http_response)
        http_response.parsed_response['id']
      end
    end
  end
end
