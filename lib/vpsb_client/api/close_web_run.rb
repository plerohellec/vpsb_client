module VpsbClient
  module Api
    class CloseWebRun < PutRequest

      def initialize(http_client, params)
        super(http_client)
        @trial_id = params[:trial_id]
        @run_id = params[:web_run_id]
        @response_counts = params[:response_counts]
      end

      def url_path
        "/api/trials/#{@trial_id}/web_runs/#{@run_id}/close"
      end

      def put_params
        @put_params = { response_counts: @response_counts }
      end

      def content_type
        'application/json'
      end
    end
  end
end
