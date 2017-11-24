module VpsbClient
  module Api
    class CreateEnduranceMetric < PostRequest

      def initialize(http_client, trial_id, endurance_run_id, metric_params)
        super(http_client)
        @trial_id = trial_id
        @run_id = endurance_run_id
        @metric_params = metric_params
      end

      def url_path
        "/api/trials/#{@trial_id}/endurance_run/#{@run_id}/metric"
      end

      def post_params
        @post_params = @metric_params
      end

      def content_type
        'application/json'
      end
    end
  end
end
