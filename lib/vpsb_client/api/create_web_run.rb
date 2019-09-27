module VpsbClient
  module Api
    class CreateWebRun < PostRequest

      def initialize(http_client, params)
        super(http_client)
        @trial_id = params[:trial_id]
        @web_run_type_id = params[:web_run_type_id]
      end

      def url_path
        "/api/trials/#{@trial_id}/web_runs"
      end

      def post_params
        @post_params = {
          web_run_type_id: @web_run_type_id
        }
      end

      def content_type
        'application/json'
      end
    end
  end
end
