module VpsbClient
  module Api
    class CloseWebRun < PutRequest

      def initialize(http_client, trial_id, web_run_id)
        super(http_client)
        @trial_id = trial_id
        @run_id = web_run_id
      end

      def url_path
        "/api/trials/#{@trial_id}/web_runs/#{@run_id}/close"
      end

      def put_params
        @put_params = { }
      end

      def content_type
        'application/json'
      end
    end
  end
end
