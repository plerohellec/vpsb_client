module VpsbClient
  module Api
    class CloseTrialRequest < PutRequest

      def initialize(http_client, trial_id, csrf_token)
        super(http_client, csrf_token)
        @trial_id = trial_id
      end

      def url_path
        "/admin/trials/#{@trial_id}/close"
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
