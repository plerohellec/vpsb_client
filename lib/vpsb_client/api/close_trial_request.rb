module VpsbClient
  module Api
    class CloseTrialRequest < PutRequest

      def initialize(http_client, trial_id)
        super(http_client)
        @trial_id = trial_id
      end

      def url_path
        "/api/trials/#{@trial_id}/close"
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
