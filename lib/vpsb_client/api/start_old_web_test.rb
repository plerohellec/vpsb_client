module VpsbClient
  module Api
    class StartOldWebTest < PutRequest

      def initialize(http_client, trial_id)
        super(http_client)
        @trial_id = trial_id
      end

      def url_path
        "/api/trials/#{@trial_id}/start_old_web_test"
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
