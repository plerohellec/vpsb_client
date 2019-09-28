module VpsbClient
  module Api
    class AppendWebRunMetrics < PostRequest

      def initialize(http_client, params)
        super(http_client)
        @trial_id = params[:trial_id]
        @run_id = params[:web_run_id]
        @metrics = params[:metrics]
      end

      def url_path
        "/api/trials/#{@trial_id}/web_runs/#{@run_id}/append_metrics"
      end

      def post_params
        @post_params = { web_metrics: @metrics }
      end

      def content_type
        'application/json'
      end
    end
  end
end
