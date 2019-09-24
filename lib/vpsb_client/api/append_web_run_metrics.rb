module VpsbClient
  module Api
    class AppendWebRunMetrics < PostRequest

      def initialize(http_client, trial_id, web_run_id, metrics_params)
        super(http_client)
        @trial_id = trial_id
        @run_id = web_run_id
        @metrics_params = metrics_params
      end

      def url_path
        "/api/trials/#{@trial_id}/web_runs/#{@run_id}/append_metrics"
      end

      def post_params
        @post_params = @metrics_params
      end

      def content_type
        'application/json'
      end
    end
  end
end
